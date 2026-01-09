import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../models/review_model.dart';
import '../../services/database_service.dart';
import '../reading/reading_screen.dart';
import 'rating_screen.dart';
import '../../screens/reading/smart_reading_screen.dart';

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
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Đã xóa!")));
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
              // --- HEADER ---
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: currentBook.coverColor ?? AppColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: () => _confirmDelete(context, currentBook.id!),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: currentBook.coverColor ?? AppColors.primary,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Container(
                          width: 120,
                          height: 170,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: currentBook.imageUrl.isNotEmpty
                                ? (currentBook.imageUrl.startsWith('http')
                                ? Image.network(
                              currentBook.imageUrl,
                              fit: BoxFit.cover,
                            )
                                : Image.file(
                              File(currentBook.imageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: Colors.white24),
                            ))
                                : Container(
                              color: Colors.white24,
                              child: const Icon(Icons.book,
                                  size: 50, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentBook.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentBook.author,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "${currentBook.rating} (${currentBook.reviewsCount})",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // --- BODY ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        // --- NÚT ĐỌC NGAY ---
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.menu_book, color: Colors.white),
                              label: const Text("Đọc ngay",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E293B),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                // 1. SỬA: Dùng 'readingStatus' thay vì 'status'
                                if (currentBook.readingStatus == 'wishlist') {
                                  await DatabaseService().updateBook(currentBook.id!, {
                                    'readingStatus': 'reading' // Cập nhật đúng key
                                  });
                                }

                                // 2. Điều hướng
                                if (context.mounted) {
                                  if (currentBook.assetPath != null &&
                                      currentBook.assetPath!.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SmartReadingScreen(book: currentBook),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReadingScreen(
                                            book: currentBook),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // --- NÚT ĐÁNH GIÁ ---
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFF7ED),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      RatingScreen(book: currentBook)),
                            ),
                            child: const Icon(Icons.star,
                                color: Colors.orange, size: 28),
                          ),
                        )
                      ]),

                      const SizedBox(height: 32),
                      const Text("Giới thiệu",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        currentBook.description.isNotEmpty
                            ? currentBook.description
                            : "Chưa có mô tả.",
                        style: const TextStyle(height: 1.5, color: Colors.grey),
                      ),

                      const SizedBox(height: 32),
                      const Text("Đánh giá từ cộng đồng",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      // --- LIST REVIEW ---
                      StreamBuilder<List<ReviewModel>>(
                        stream:
                        DatabaseService().getReviews(currentBook.id ?? ""),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text("Lỗi: ${snapshot.error}",
                                style: const TextStyle(color: Colors.red));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                  "Chưa có đánh giá nào. Hãy là người đầu tiên!",
                                  style: TextStyle(color: Colors.grey)),
                            );
                          }

                          return Column(
                            children: snapshot.data!
                                .map((review) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor:
                                          Colors.blue.shade50,
                                          child: Text(
                                            review.userName.isNotEmpty
                                                ? review.userName[0]
                                                .toUpperCase()
                                                : "?",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review.userName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                            ),
                                            Text(
                                              "${review.createdAt.day}/${review.createdAt.month}",
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ]),
                                      Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2),
                                        decoration: BoxDecoration(
                                            color:
                                            Colors.amber.shade100,
                                            borderRadius:
                                            BorderRadius.circular(8)),
                                        child: Row(children: [
                                          const Icon(Icons.star,
                                              size: 12,
                                              color: Colors.orange),
                                          Text(
                                            " ${review.rating}",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange.shade900),
                                          )
                                        ]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(review.comment,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          height: 1.4)),
                                ],
                              ),
                            ))
                                .toList(),
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