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

  // 1. Thêm sách
  Future<void> addBook(BookModel book) async {
    try {
      Map<String, dynamic> data = book.toMap();
      data['userId'] = FirebaseAuth.instance.currentUser?.uid;
      if (data['isPublic'] == null) {
        data['isPublic'] = false;
      }

      String content = data['content'] ?? "";
      int currentTotalPages = data['totalPages'] ?? 0;

      if (content.isNotEmpty && currentTotalPages <= 0) {
        int calculatedPages = (content.length / 1500).ceil();
        if (calculatedPages < 1) calculatedPages = 1;
        data['totalPages'] = calculatedPages;
        print("⚡ Đã tự động tính lại số trang: $calculatedPages trang");
      }

      await _bookRef.doc(book.id).set(data);
    } catch (e) {
      print("❌ Lỗi lưu sách: $e");
      rethrow;
    }
  }

  // 2. Lấy sách
  Stream<List<BookModel>> getBooks() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _bookRef.where('userId', isEqualTo: uid).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 3. Lấy sách cộng đồng
  Stream<List<BookModel>> getPublicBooks() {
    return _bookRef
        .where('isPublic', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 4. Clone sách
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
        'rating': 0.0,
        'reviewsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'originalBookId': publicBook.id,
        'source': 'cloned',
        'keyTakeaways': [],
      });
    } catch (e) {
      print("❌ Lỗi clone sách: $e");
      rethrow;
    }
  }

  // 5. Xóa sách
  Future<void> deleteBook(String bookId) async {
    try {
      await _bookRef.doc(bookId).delete();
      final reviewsSnapshot =
      await _reviewRef.where('bookId', isEqualTo: bookId).get();
      for (var doc in reviewsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("❌ Lỗi xóa sách: $e");
      rethrow;
    }
  }

  Stream<BookModel> getBookStream(String bookId) {
    return _bookRef.doc(bookId).snapshots().map((doc) {
      if (doc.exists) {
        return BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        return BookModel(
            id: 'error',
            title: 'Không tìm thấy',
            author: '',
            description: '',
            content: '',
            imageUrl: '',
            totalPages: 0,
            createdAt: DateTime.now());
      }
    });
  }

  // 6. Thêm Review
  Future<void> addReview(ReviewModel review, BookModel currentBook) async {
    try {
      await _reviewRef.doc(review.id).set(review.toMap());
      DocumentSnapshot doc = await _bookRef.doc(currentBook.id).get();
      if (!doc.exists) return;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      double serverRating = (data['rating'] ?? 0.0).toDouble();
      int serverCount = (data['reviewsCount'] ?? 0).toInt();

      double newRating =
          ((serverRating * serverCount) + review.rating) / (serverCount + 1);
      newRating = double.parse(newRating.toStringAsFixed(1));

      await _bookRef.doc(currentBook.id).update({
        'rating': newRating,
        'reviewsCount': serverCount + 1,
      });
    } catch (e) {
      print("❌ Lỗi lưu review: $e");
      rethrow;
    }
  }

  Stream<List<ReviewModel>> getReviews(String bookId) {
    return _reviewRef
        .where('bookId', isEqualTo: bookId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
          ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // 7. Lưu câu hỏi AI
  Future<int> saveAICreatedFlashcards(
      String bookId, List<Map<String, dynamic>> flashcards) async {
    try {
      final CollectionReference flashRef =
      _bookRef.doc(bookId).collection('flashcards');

      final existingSnapshot = await flashRef.get();
      final Set<String> existingQuestions = existingSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['question']
          .toString()
          .toLowerCase()
          .trim())
          .toSet();

      int addedCount = 0;

      for (var card in flashcards) {
        String newQuestion = card['question'].toString().toLowerCase().trim();

        if (!existingQuestions.contains(newQuestion)) {
          await flashRef.add({
            'question': card['question'],
            'answer': card['answer'],
            'createdAt': FieldValue.serverTimestamp(),
            'nextReview': DateTime.now().millisecondsSinceEpoch,
            'level': 'new',
          });
          addedCount++;
        }
      }
      print("✅ Đã thêm $addedCount câu hỏi mới (Bỏ qua trùng lặp)");
      return addedCount;
    } catch (e) {
      print("❌ Lỗi lưu Flashcards: $e");
      rethrow;
    }
  }

  Future<void> updateFlashcardLevel(
      String bookId, String cardId, String level) async {
    try {
      DateTime now = DateTime.now();
      int nextReview = now.add(const Duration(days: 4)).millisecondsSinceEpoch;
      if (level == 'hard') {
        nextReview = now.add(const Duration(minutes: 10)).millisecondsSinceEpoch;
      }
      if (level == 'good') {
        nextReview = now.add(const Duration(days: 1)).millisecondsSinceEpoch;
      }

      await _bookRef
          .doc(bookId)
          .collection('flashcards')
          .doc(cardId)
          .update({
        'level': level,
        'nextReview': nextReview,
      });
    } catch (e) {
      print("❌ Lỗi: $e");
    }
  }

  // 8. Cập nhật thông tin sách (HÀM NÀY ĐÃ ĐƯỢC THÊM ĐỂ SỬA LỖI)
  Future<void> updateBook(String bookId, Map<String, dynamic> data) async {
    try {
      await _bookRef.doc(bookId).update(data);
    } catch (e) {
      print("❌ Lỗi updateBook: $e");
      rethrow;
    }
  }
}