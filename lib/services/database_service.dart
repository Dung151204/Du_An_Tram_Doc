// File: lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../models/review_model.dart'; // <--- Nhớ import cái này

class DatabaseService {
  // 1. KẾT NỐI TỚI KHO
  final CollectionReference _bookRef = FirebaseFirestore.instance.collection('books');
  final CollectionReference _reviewRef = FirebaseFirestore.instance.collection('reviews'); // <--- Mới thêm kho review

  // --- PHẦN XỬ LÝ SÁCH (Cũ) ---

  // Thêm sách
  Future<void> addBook(BookModel book) async {
    try {
      await _bookRef.doc(book.id).set(book.toMap());
      print("✅ Đã lưu sách: ${book.title}");
    } catch (e) {
      print("❌ Lỗi lưu sách: $e");
      rethrow;
    }
  }

  // Lấy danh sách sách
  Stream<List<BookModel>> getBooks() {
    return _bookRef.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // --- PHẦN XỬ LÝ REVIEW (MỚI BỔ SUNG) ---

  // 1. Hàm gửi đánh giá lên Firebase
  Future<void> addReview(ReviewModel review) async {
    try {
      await _reviewRef.doc(review.id).set(review.toMap());
      print("✅ Đã lưu review của: ${review.userName}");
    } catch (e) {
      print("❌ Lỗi lưu review: $e");
      rethrow;
    }
  }

  // 2. Hàm lấy danh sách đánh giá của 1 cuốn sách cụ thể
  Stream<List<ReviewModel>> getReviews(String bookId) {
    return _reviewRef
        .where('bookId', isEqualTo: bookId) // Chỉ lấy review của cuốn sách này
        .orderBy('createdAt', descending: true) // Mới nhất lên đầu
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
  // --- THÊM HÀM NÀY VÀO CUỐI CLASS ---

  // 3. Hàm Xóa sách
  Future<void> deleteBook(String bookId) async {
    try {
      await _bookRef.doc(bookId).delete();
      print("🗑️ Đã xóa sách: $bookId");
    } catch (e) {
      print("❌ Lỗi xóa sách: $e");
      rethrow;
    }
  }
}