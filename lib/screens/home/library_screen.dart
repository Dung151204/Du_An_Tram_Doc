import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../services/database_service.dart';
import '../book_details/book_detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 Tab: Đang đọc, Muốn đọc, Đã đọc
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black), // Nút quay lại HomeScreen
          title: const Text(
            "Thư viện thông minh",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Đang đọc"),
              Tab(text: "Muốn đọc"),
              Tab(text: "Đã đọc"),
            ],
          ),
        ),
        body: StreamBuilder<List<BookModel>>(
          stream: DatabaseService().getBooks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Lỗi: ${snapshot.error}"));
            }

            final allBooks = snapshot.data ?? [];

            // --- LỌC SÁCH DỰA VÀO readingStatus ---
            // 1. Đang đọc
            final readingBooks = allBooks
                .where((b) => b.readingStatus == 'reading')
                .toList();

            // 2. Muốn đọc (Wishlist)
            final wishlistBooks = allBooks
                .where((b) => b.readingStatus == 'wishlist')
                .toList();

            // 3. Đã đọc (Completed) - Đây là chỗ giúp sách hiện lại
            final completedBooks = allBooks
                .where((b) => b.readingStatus == 'completed')
                .toList();
            // ----------------------------------------------

            return TabBarView(
              children: [
                _buildBookList(context, readingBooks, "Chưa có sách đang đọc"),
                _buildBookList(context, wishlistBooks, "Danh sách muốn đọc trống"),
                _buildBookList(context, completedBooks, "Bạn chưa hoàn thành cuốn nào"),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookList(BuildContext context, List<BookModel> books, String emptyMessage) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookDetailScreen(book: book),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Ảnh bìa
                Container(
                  width: 70,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: book.coverColor ?? Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: book.imageUrl.isNotEmpty
                        ? (book.imageUrl.startsWith('http')
                        ? Image.network(book.imageUrl, fit: BoxFit.cover)
                        : Image.file(File(book.imageUrl), fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.book, color: Colors.white)))
                        : const Icon(Icons.book, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                // Thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      // Thanh tiến độ
                      if (book.readingStatus != 'wishlist')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: book.totalPages > 0
                                  ? (book.currentPage / book.totalPages)
                                  : 0,
                              backgroundColor: Colors.grey.shade200,
                              color: book.readingStatus == 'completed'
                                  ? Colors.green
                                  : AppColors.primary,
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.readingStatus == 'completed'
                                  ? "Hoàn thành 100%"
                                  : "Đã đọc ${book.currentPage}/${book.totalPages} trang",
                              style: TextStyle(
                                fontSize: 12,
                                color: book.readingStatus == 'completed'
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      if (book.readingStatus == 'wishlist')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4)
                          ),
                          child: const Text(
                            "Muốn đọc",
                            style: TextStyle(fontSize: 10, color: Colors.orange),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}