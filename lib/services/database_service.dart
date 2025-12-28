import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../models/review_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _bookRef = FirebaseFirestore.instance.collection('books');
  final CollectionReference _reviewRef = FirebaseFirestore.instance.collection('reviews');

  // --- PHẦN XỬ LÝ SÁCH ---

  // 1. Thêm sách
  Future<void> addBook(BookModel book) async {
    try {
      await _bookRef.doc(book.id).set(book.toMap());
    } catch (e) {
      print("❌ Lỗi lưu sách: $e");
      rethrow;
    }
  }

  // 2. Lấy danh sách sách (Cho màn hình Home)
  Stream<List<BookModel>> getBooks() {
    return _bookRef.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 3. (QUAN TRỌNG) Theo dõi 1 cuốn sách cụ thể (Cho màn hình Chi tiết)
  // Hàm này giúp cập nhật số sao ngay lập tức
  Stream<BookModel> getBookStream(String bookId) {
    return _bookRef.doc(bookId).snapshots().map((doc) {
      if (doc.exists) {
        return BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        // Trả về sách rỗng nếu lỗi (để tránh crash app)
        return BookModel(
            id: 'error',
            title: 'Không tìm thấy',
            author: '', description: '', content: '', imageUrl: '',
            totalPages: 0, createdAt: DateTime.now()
        );
      }
    });
  }

  // 4. Xóa sách
  Future<void> deleteBook(String bookId) async {
    try {
      await _bookRef.doc(bookId).delete();

      // Xóa luôn các review liên quan đến sách này
      final reviewsSnapshot = await _reviewRef.where('bookId', isEqualTo: bookId).get();
      for (var doc in reviewsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("❌ Lỗi xóa sách: $e");
      rethrow;
    }
  }

  // --- PHẦN XỬ LÝ REVIEW & TÍNH ĐIỂM ---

  // 5. Thêm đánh giá & Tính lại điểm trung bình
  Future<void> addReview(ReviewModel review, BookModel currentBook) async {
    try {
      // B1: Lưu bài review
      await _reviewRef.doc(review.id).set(review.toMap());

      // B2: Tính toán điểm trung bình mới
      // Công thức: ((Điểm cũ * Số lượng cũ) + Điểm mới) / (Số lượng cũ + 1)
      double oldRating = currentBook.rating;
      int oldCount = currentBook.reviewsCount;

      double newRating = ((oldRating * oldCount) + review.rating) / (oldCount + 1);

      // Làm tròn 1 chữ số thập phân (VD: 4.66 -> 4.7)
      newRating = double.parse(newRating.toStringAsFixed(1));

      // B3: Cập nhật lại sách với điểm mới
      await _bookRef.doc(currentBook.id).update({
        'rating': newRating,
        'reviewsCount': oldCount + 1,
      });

      print("✅ Đã review và cập nhật rating mới: $newRating");
    } catch (e) {
      print("❌ Lỗi lưu review: $e");
      rethrow;
    }
  }

  // 6. Lấy danh sách review của 1 cuốn sách
  Stream<List<ReviewModel>> getReviews(String bookId) {
    return _reviewRef
        .where('bookId', isEqualTo: bookId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}