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
      data['createdAt'] = FieldValue.serverTimestamp(); // Sửa lỗi Timestamp cho đồng bộ

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
        // Xử lý Timestamp thành int để khớp Model cũ
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
        }
        return BookModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  // Hàm bổ trợ: Lấy danh sách ID các cuốn sách của User hiện tại
  Future<List<String>> getUserBookIds() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _bookRef.where('userId', isEqualTo: uid).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // --- Các hàm khác (getPublicBooks, cloneBook, deleteBook, addReview...) giữ nguyên ---

  Stream<List<BookModel>> getBooks() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return getBooksByUserId(uid);
  }

  Stream<List<BookModel>> getPublicBooks() {
    return _bookRef.where('isPublic', isEqualTo: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).millisecondsSinceEpoch;
        }
        return BookModel.fromMap(data, doc.id);
      }).toList();
    });
  }

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

  Future<void> addReview(ReviewModel review, BookModel currentBook) async {
    try {
      await _reviewRef.doc(review.id).set(review.toMap());
      DocumentSnapshot doc = await _bookRef.doc(currentBook.id).get();
      if (!doc.exists) return;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      double serverRating = (data['rating'] ?? 0.0).toDouble();
      int serverCount = (data['reviewsCount'] ?? 0).toInt();
      double newRating = ((serverRating * serverCount) + review.rating) / (serverCount + 1);
      newRating = double.parse(newRating.toStringAsFixed(1));
      await _bookRef.doc(currentBook.id).update({'rating': newRating, 'reviewsCount': serverCount + 1});
    } catch (e) { print("❌ Lỗi review: $e"); rethrow; }
  }

  Stream<List<ReviewModel>> getReviews(String bookId) {
    return _reviewRef.where('bookId', isEqualTo: bookId).snapshots().map((snapshot) {
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

  // --- TÍNH NĂNG MẠNG XÃ HỘI (Follow) ---

  // 1. Tìm kiếm người dùng theo tên (Gần đúng)
  Stream<QuerySnapshot> searchUsers(String query) {
    return _firestore
        .collection('users')
        .where('fullName', isGreaterThanOrEqualTo: query)
        .where('fullName', isLessThan: query + 'z')
        .snapshots();
  }

  // 2. Kiểm tra xem mình đã theo dõi người này chưa
  Stream<bool> isFollowing(String targetUserId) {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return Stream.value(false);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following') // Sub-collection lưu danh sách đang theo dõi
        .doc(targetUserId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // 3. Bấm nút Theo dõi / Hủy theo dõi
  Future<void> toggleFollow(String targetUserId) async {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    DocumentReference followingDoc = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId);

    final docSnapshot = await followingDoc.get();

    if (docSnapshot.exists) {
      // Nếu đã theo dõi -> Xóa (Hủy theo dõi)
      await followingDoc.delete();
    } else {
      // Nếu chưa theo dõi -> Thêm vào
      await followingDoc.set({
        'followedAt': FieldValue.serverTimestamp(),
      });
    }
  }
  // --- TÍNH NĂNG CHUỖI ĐỌC SÁCH (STREAK) ---
  Future<void> updateReadingStreak() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    DocumentReference userDoc = _firestore.collection('users').doc(uid);
    DocumentSnapshot snapshot = await userDoc.get();

    if (!snapshot.exists) return;

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    // Lấy dữ liệu cũ
    int currentStreak = data['currentStreak'] ?? 0;
    String? lastReadingDateStr = data['lastReadingDate']; // Lưu dạng yyyy-MM-dd

    // Ngày hôm nay
    String todayStr = DateTime.now().toIso8601String().split('T')[0];

    // Logic tính chuỗi
    if (lastReadingDateStr == todayStr) {
      // Đã tính điểm hôm nay rồi -> Không làm gì cả
      return;
    }

    DateTime today = DateTime.parse(todayStr);
    DateTime? lastDate = lastReadingDateStr != null ? DateTime.parse(lastReadingDateStr) : null;

    if (lastDate != null && today.difference(lastDate).inDays == 1) {
      // Nếu ngày đọc cuối là hôm qua -> Tăng chuỗi
      currentStreak++;
    } else {
      // Nếu bỏ lỡ một ngày hoặc mới đọc lần đầu -> Reset về 1
      currentStreak = 1;
    }

    // Cập nhật lên Firebase
    await userDoc.update({
      'currentStreak': currentStreak,
      'lastReadingDate': todayStr,
    });

    print("🔥 Đã cập nhật chuỗi: $currentStreak ngày");
  }
}