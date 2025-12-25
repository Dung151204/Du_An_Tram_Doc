import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../models/review_model.dart';
import '../../services/database_service.dart';
import '../reading/reading_screen.dart';
import 'rating_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final BookModel book;

  const BookDetailScreen({super.key, required this.book});

  // HÀM XỬ LÝ XÓA SÁCH
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa sách?"),
        content: const Text("Hành động này không thể hoàn tác. Bạn chắc chứ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Đóng hộp thoại
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Đóng hộp thoại trước
              try {
                // Gọi hàm xóa
                await DatabaseService().deleteBook(book.id!);

                if (context.mounted) {
                  Navigator.pop(context); // Đóng màn hình chi tiết, quay về Tủ sách
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã xóa sách thành công!"), backgroundColor: Colors.green)
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red)
                  );
                }
              }
            },
            child: const Text("Xóa luôn", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350, pinned: true,
            backgroundColor: book.coverColor ?? AppColors.primary,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),

            // --- THÊM NÚT THÙNG RÁC Ở ĐÂY ---
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => _confirmDelete(context),
              ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: book.coverColor ?? AppColors.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: book.imageUrl.isNotEmpty
                            ? (book.imageUrl.startsWith('http')
                            ? Image.network(book.imageUrl, width: 140, height: 210, fit: BoxFit.cover)
                            : Image.file(File(book.imageUrl), width: 140, height: 210, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(width: 140, height: 210, color: Colors.white24)))
                            : Container(width: 140, height: 210, color: Colors.white24, child: const Icon(Icons.book, size: 50, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(book.title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(book.author, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),

          // Phần nội dung bên dưới giữ nguyên
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.menu_book, color: Colors.white),
                        label: const Text("Đọc ngay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ReadingScreen(bookTitle: book.title, content: book.content)));
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                      child: IconButton(
                        icon: const Icon(Icons.star, color: Colors.orange),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => RatingScreen(book: book)));
                        },
                      ),
                    )
                  ]),
                  const SizedBox(height: 30),
                  const Text("Giới thiệu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(book.description.isNotEmpty ? book.description : "Chưa có mô tả.", style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 30),
                  const Text("Đánh giá", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  StreamBuilder<List<ReviewModel>>(
                    stream: DatabaseService().getReviews(book.id ?? ""),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("Chưa có đánh giá nào.", style: TextStyle(color: Colors.grey));
                      return Column(
                        children: snapshot.data!.map((review) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(child: Text(review.userName.isNotEmpty ? review.userName[0] : "?")),
                          title: Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(review.comment),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, size: 14, color: Colors.amber), Text("${review.rating}")]),
                        )).toList(),
                      );
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}