import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../models/review_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _bookRef =
  FirebaseFirestore.instance.collection('books');
  final CollectionReference _reviewRef =
  FirebaseFirestore.instance.collection('reviews');

  // --- HÀM THÊM NỘI DUNG VÀO CUỐI SÁCH ---
  Future<void> appendBookContent(String bookId, String newText) async {
    try {
      DocumentReference docRef = _bookRef.doc(bookId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        String oldContent = snapshot.get('content') ?? "";
        String updatedContent = oldContent + "\n\n" + newText;

        int updatedTotalPages = (updatedContent.length / 1500).ceil();
        if (updatedTotalPages < 1) updatedTotalPages = 1;

        transaction.update(docRef, {
          'content': updatedContent,
          'totalPages': updatedTotalPages,
        });
      });
      print("✅ Đã cập nhật nội dung và đồng bộ thành công");
    } catch (e) {
      print("❌ Lỗi cập nhật nội dung: $e");
      rethrow;
    }
  }

  // 1. Thêm sách
  Future<void> addBook(BookModel book) async {
    try {
      Map<String, dynamic> data = book.toMap();
      data['userId'] = FirebaseAuth.instance.currentUser?.uid;
      if (data['isPublic'] == null) {
        data['isPublic'] = false;
      }
      data['createdAt'] = FieldValue.serverTimestamp();

      String content = data['content'] ?? "";
      int currentTotalPages = data['totalPages'] ?? 0;

      if (content.isNotEmpty && currentTotalPages <= 0) {
        int calculatedPages = (content.length / 1500).ceil();
        if (calculatedPages < 1) calculatedPages = 1;
        data['totalPages'] = calculatedPages;
      }

      await _bookRef.doc(book.id).set(data);
    } catch (e) {
      print("❌ Lỗi lưu sách: $e");
      rethrow;
    }
  }

  // 2. Lấy sách cá nhân
  Stream<List<BookModel>> getBooksByUserId(String userId) {
    return _bookRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
        }
        return BookModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  Future<List<String>> getUserBookIds() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _bookRef.where('userId', isEqualTo: uid).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Stream<List<BookModel>> getBooks() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return getBooksByUserId(uid);
  }

  Stream<List<BookModel>> getPublicBooks() {
    String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    return _bookRef.where('isPublic', isEqualTo: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
        }
        return BookModel.fromMap(data, doc.id);
      }).where((book) => book.userId != currentUid).toList();
    });
  }

  // SỬA LỖI: Clone giữ liên kết originalBookId
  Future<void> cloneBookToLibrary(BookModel publicBook) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await _bookRef.add({
        'title': publicBook.title,
        'author': publicBook.author,
        'imageUrl': publicBook.imageUrl,
        'description': publicBook.description,
        'totalPages': publicBook.totalPages,
        'content': publicBook.content,
        'colorValue': publicBook.colorValue ?? publicBook.coverColor?.value,
        'userId': uid,
        'isPublic': false,
        'readingStatus': 'wishlist',
        'currentPage': 0,
        'rating': publicBook.rating,
        'reviewsCount': publicBook.reviewsCount,
        'createdAt': FieldValue.serverTimestamp(),
        'originalBookId': publicBook.id, // Lưu ID gốc
        'source': 'cloned',
        'keyTakeaways': [],
      });
    } catch (e) { print("❌ Lỗi clone: $e"); rethrow; }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _bookRef.doc(bookId).delete();
      final reviewsSnapshot = await _reviewRef.where('bookId', isEqualTo: bookId).get();
      for (var doc in reviewsSnapshot.docs) { await doc.reference.delete(); }
    } catch (e) { print("❌ Lỗi xóa: $e"); rethrow; }
  }

  Stream<BookModel> getBookStream(String bookId) {
    return _bookRef.doc(bookId).snapshots().map((doc) {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
        }
        return BookModel.fromMap(data, doc.id);
      } else {
        return BookModel(id: 'error', title: 'Không tìm thấy', author: '', imageUrl: '', totalPages: 0, createdAt: DateTime.now());
      }
    });
  }

  // --- SỬA LỖI ĐÁNH GIÁ CHUNG ---
  Future<void> addReview(ReviewModel review, BookModel currentBook) async {
    try {
      String targetBookId = (currentBook.originalBookId != null && currentBook.originalBookId!.isNotEmpty)
          ? currentBook.originalBookId!
          : currentBook.id!;

      Map<String, dynamic> reviewData = review.toMap();
      reviewData['bookId'] = targetBookId;
      await _reviewRef.doc(review.id).set(reviewData);

      DocumentSnapshot doc = await _bookRef.doc(targetBookId).get();
      if (!doc.exists) return;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      double serverRating = (data['rating'] ?? 0.0).toDouble();
      int serverCount = (data['reviewsCount'] ?? 0).toInt();

      double newRating = ((serverRating * serverCount) + review.rating) / (serverCount + 1);
      newRating = double.parse(newRating.toStringAsFixed(1));

      await _bookRef.doc(targetBookId).update({
        'rating': newRating,
        'reviewsCount': serverCount + 1
      });
    } catch (e) { print("❌ Lỗi review: $e"); rethrow; }
  }

  // --- SỬA LỖI HIỂN THỊ BÌNH LUẬN CHUNG ---
  Stream<List<ReviewModel>> getReviews(String bookId) {
    // Logic: Trước khi lấy review, phải kiểm tra xem bookId này có trỏ về gốc không
    return _bookRef.doc(bookId).snapshots().asyncMap((bookSnap) async {
      String finalId = bookId;
      if (bookSnap.exists) {
        final data = bookSnap.data() as Map<String, dynamic>;
        // Nếu là sách clone, lấy ID bản gốc để hiển thị bình luận cộng đồng
        if (data['originalBookId'] != null && data['originalBookId'].toString().isNotEmpty) {
          finalId = data['originalBookId'];
        }
      }
      final snapshot = await _reviewRef.where('bookId', isEqualTo: finalId).get();
      return snapshot.docs.map((doc) => ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  Future<int> saveAICreatedFlashcards(String bookId, List<Map<String, dynamic>> flashcards) async {
    try {
      final CollectionReference flashRef = _bookRef.doc(bookId).collection('flashcards');
      final existingSnapshot = await flashRef.get();
      final Set<String> existingQuestions = existingSnapshot.docs.map((doc) => (doc.data() as Map<String, dynamic>)['question'].toString().toLowerCase().trim()).toSet();
      int addedCount = 0;
      for (var card in flashcards) {
        String newQuestion = card['question'].toString().toLowerCase().trim();
        if (!existingQuestions.contains(newQuestion)) {
          await flashRef.add({
            'question': card['question'], 'answer': card['answer'],
            'createdAt': FieldValue.serverTimestamp(),
            'nextReview': DateTime.now().millisecondsSinceEpoch, 'level': 'new',
          });
          addedCount++;
        }
      }
      return addedCount;
    } catch (e) { print("❌ Lỗi Flashcards: $e"); rethrow; }
  }

  Future<void> updateFlashcardLevel(String bookId, String cardId, String level) async {
    try {
      DateTime now = DateTime.now();
      int nextReview = now.add(const Duration(days: 4)).millisecondsSinceEpoch;
      if (level == 'hard') nextReview = now.add(const Duration(minutes: 10)).millisecondsSinceEpoch;
      if (level == 'good') nextReview = now.add(const Duration(days: 1)).millisecondsSinceEpoch;
      await _bookRef.doc(bookId).collection('flashcards').doc(cardId).update({'level': level, 'nextReview': nextReview});
    } catch (e) { print("❌ Lỗi: $e"); }
  }

  Future<void> updateBook(String bookId, Map<String, dynamic> data) async {
    try { await _bookRef.doc(bookId).update(data); } catch (e) { print("❌ Lỗi update: $e"); rethrow; }
  }
}