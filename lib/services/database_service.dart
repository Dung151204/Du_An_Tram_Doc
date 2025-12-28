import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../models/review_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _bookRef = FirebaseFirestore.instance.collection('books');
  final CollectionReference _reviewRef = FirebaseFirestore.instance.collection('reviews');

  // 1. Thêm sách (GIỮ NGUYÊN)
  Future<void> addBook(BookModel book) async {
    try {
      Map<String, dynamic> data = book.toMap();
      data['userId'] = FirebaseAuth.instance.currentUser?.uid;
      if (data['isPublic'] == null) {
        data['isPublic'] = false;
      }
      await _bookRef.doc(book.id).set(data);
    } catch (e) {
      print("❌ Lỗi lưu sách: $e");
      rethrow;
    }
  }

  // 2. Lấy sách (SỬA ĐỂ HIỆN SÁCH NGAY)
  Stream<List<BookModel>> getBooks() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _bookRef
        .where('userId', isEqualTo: uid)
    // .orderBy('createdAt', descending: true) // <--- TÔI ĐÃ ẨN DÒNG NÀY ĐỂ TRÁNH LỖI INDEX
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 3. Lấy sách KHO CHUNG (GIỮ NGUYÊN)
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

  // 4. Clone sách (GIỮ NGUYÊN)
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
        'status': 'reading',
        'currentPage': 0,
        'rating': 0.0,
        'reviewsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'originalBookId': publicBook.id,
        'source': 'cloned',
      });
    } catch (e) {
      print("❌ Lỗi clone sách: $e");
      rethrow;
    }
  }

  // 5. Xóa sách (GIỮ NGUYÊN)
  Future<void> deleteBook(String bookId) async {
    try {
      await _bookRef.doc(bookId).delete();
      final reviewsSnapshot = await _reviewRef.where('bookId', isEqualTo: bookId).get();
      for (var doc in reviewsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("❌ Lỗi xóa sách: $e");
      rethrow;
    }
  }

  // ... Các hàm review (GIỮ NGUYÊN) ...
  Stream<BookModel> getBookStream(String bookId) {
    return _bookRef.doc(bookId).snapshots().map((doc) {
      if (doc.exists) {
        return BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        return BookModel(id: 'error', title: 'Không tìm thấy', author: '', description: '', content: '', imageUrl: '', totalPages: 0, createdAt: DateTime.now());
      }
    });
  }

  Future<void> addReview(ReviewModel review, BookModel currentBook) async {
    await _reviewRef.doc(review.id).set(review.toMap());
  }

  Stream<List<ReviewModel>> getReviews(String bookId) {
    return _reviewRef.where('bookId', isEqualTo: bookId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }
}