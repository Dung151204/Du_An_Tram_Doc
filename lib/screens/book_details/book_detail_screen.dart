import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../models/review_model.dart'; // Đảm bảo file này đã được tạo và Save
import '../../services/database_service.dart';
import '../reading/reading_screen.dart';
import 'rating_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final BookModel initialBook;

  const BookDetailScreen({super.key, required this.book}) : initialBook = book;
  final BookModel book;

  void _confirmDelete(BuildContext context, String bookId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa sách?"),
        content: const Text("Hành động này không thể hoàn tác."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseService().deleteBook(bookId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa!")));
              }
            },
            child: const Text("Xóa luôn", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BookModel>(
      stream: DatabaseService().getBookStream(initialBook.id ?? ""),
      initialData: initialBook,
      builder: (context, bookSnapshot) {
        final currentBook = bookSnapshot.data ?? initialBook;

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350, pinned: true,
                backgroundColor: currentBook.coverColor ?? AppColors.primary,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                actions: [
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.white), onPressed: () => _confirmDelete(context, currentBook.id!)),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: currentBook.coverColor ?? AppColors.primary,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: currentBook.imageUrl.isNotEmpty
                                ? (currentBook.imageUrl.startsWith('http')
                                ? Image.network(currentBook.imageUrl, width: 140, height: 210, fit: BoxFit.cover)
                                : Image.file(File(currentBook.imageUrl), width: 140, height: 210, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(width: 140, height: 210, color: Colors.white24)))
                                : Container(width: 140, height: 210, color: Colors.white24, child: const Icon(Icons.book, size: 50, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(currentBook.title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(currentBook.author, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text("${currentBook.rating}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(" (${currentBook.reviewsCount} đánh giá)", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

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
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReadingScreen(bookTitle: currentBook.title, content: currentBook.content))),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                          child: IconButton(
                            icon: const Icon(Icons.star, color: Colors.orange),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RatingScreen(book: currentBook))),
                          ),
                        )
                      ]),
                      const SizedBox(height: 30),
                      const Text("Giới thiệu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(currentBook.description.isNotEmpty ? currentBook.description : "Chưa có mô tả.", style: const TextStyle(height: 1.5)),

                      const SizedBox(height: 30),
                      const Text("Đánh giá từ cộng đồng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      StreamBuilder<List<ReviewModel>>(
                        stream: DatabaseService().getReviews(currentBook.id ?? ""),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return Text("Lỗi tải đánh giá: ${snapshot.error}", style: const TextStyle(color: Colors.red));
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                children: const [
                                  Icon(Icons.rate_review_outlined, size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text("Chưa có đánh giá nào.\nHãy là người đầu tiên!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: snapshot.data!.map((review) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.blue.shade50,
                                            child: Text(review.userName.isNotEmpty ? review.userName[0].toUpperCase() : "?", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            Text(
                                                "${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}",
                                                style: const TextStyle(fontSize: 10, color: Colors.grey)
                                            ),
                                          ],
                                        ),
                                      ]),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                                        child: Row(children: [
                                          const Icon(Icons.star, size: 12, color: Colors.orange),
                                          // --- ĐÃ SỬA: Xóa const ở đây ---
                                          Text(" ${review.rating}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade900))
                                        ]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(review.comment, style: const TextStyle(color: Colors.black87, height: 1.4)),
                                ],
                              ),
                            )).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}