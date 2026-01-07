import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/book_model.dart';
import '../../services/database_service.dart';
import '../book_details/book_detail_screen.dart';
import '../add_book/add_book_sheet.dart'; // Import để gọi thêm sách

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // Dialog cập nhật tiến độ (FR1.3)
  void _showUpdateProgressDialog(BuildContext context, BookModel book) {
    final TextEditingController pageController = TextEditingController(text: book.currentPage.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cập nhật tiến độ"),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Số trang đã đọc (Tổng: ${book.totalPages})", border: const OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              int newPage = int.tryParse(pageController.text) ?? book.currentPage;
              if (newPage > book.totalPages) newPage = book.totalPages;
              FirebaseFirestore.instance.collection('books').doc(book.id).update({'currentPage': newPage});
              Navigator.pop(ctx);
            },
            child: const Text("Lưu"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Thư viện thông minh", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          // Nút thêm sách ngay trong module này
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.orange, size: 30),
            onPressed: () {
              showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const AddBookSheet());
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue[800],
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue[800],
          tabs: const [
            Tab(text: "Đang đọc"),
            Tab(text: "Muốn đọc"),
            Tab(text: "Đã đọc"),
          ],
        ),
      ),
      body: StreamBuilder<List<BookModel>>(
        stream: DatabaseService().getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final allBooks = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: [
              _buildShelf(allBooks.where((b) => b.readingStatus == 'reading').toList(), true),
              _buildShelf(allBooks.where((b) => b.readingStatus == 'want_to_read').toList(), false),
              _buildShelf(allBooks.where((b) => b.readingStatus == 'read').toList(), false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShelf(List<BookModel> books, bool showProgress) {
    if (books.isEmpty) return const Center(child: Text("Kệ sách trống", style: TextStyle(color: Colors.grey)));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      separatorBuilder: (_,__) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final book = books[index];
        double percent = book.totalPages > 0 ? (book.currentPage / book.totalPages) : 0.0;

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book))),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(width: 60, height: 90, color: book.coverColor ?? Colors.grey[200], child: book.imageUrl.isNotEmpty ? Image.network(book.imageUrl, fit: BoxFit.cover) : null),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(book.author, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      if (showProgress) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: percent, color: Colors.orange, backgroundColor: Colors.grey[100]),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _showUpdateProgressDialog(context, book),
                          child: Text("Cập nhật: ${(percent*100).toInt()}%", style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                        )
                      ]
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}