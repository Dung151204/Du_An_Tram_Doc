import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';

class SeedDataService {
  Future<void> seedSampleBooks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("⚠️ LỖI: Bạn chưa đăng nhập!");
      return;
    }

    final booksRef = FirebaseFirestore.instance.collection('books');

    final book1 = BookModel(
      id: 'sample_nha_gia_kim_${user.uid}',
      title: "Nhà Giả Kim",
      author: "Paulo Coelho",
      description: "Tất cả những gì cậu cần làm là ngắm nhìn thế giới...",
      content: """
      Cậu bé chăn cừu Santiago mơ về kho báu ở Kim Tự Tháp Ai Cập.
      (Dữ liệu tóm tắt cho AI đọc)...
      """,
      imageUrl: "",
      totalPages: 228,
      createdAt: DateTime.now(),
      userId: user.uid,
      isPublic: false,

      // SỬA Ở ĐÂY: Dùng readingStatus thay vì status
      readingStatus: 'reading',

      // Đường dẫn PDF
      assetPath: "assets/books/nha_gia_kim.pdf",
    );

    try {
      await booksRef.doc(book1.id).set(book1.toMap());
      print("✅ Đã nạp thành công sách: Nhà Giả Kim");
    } catch (e) {
      print("❌ Lỗi nạp dữ liệu: $e");
    }
  }
}