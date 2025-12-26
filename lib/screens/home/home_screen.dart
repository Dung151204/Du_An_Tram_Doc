// File: lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Nếu lỗi Lucide thì đổi thành Icons thường như mình đã chỉ
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../services/database_service.dart';
import '../book_details/book_detail_screen.dart'; // <--- Đã kết nối màn hình Chi Tiết
import '../book_details/book_preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTab = 'reading';

  // Dữ liệu giả cho tab Khám phá
  final List<Map<String, dynamic>> _discoveryBooks = [
    {"title": "Tư duy nhanh chậm", "author": "Daniel Kahneman", "rating": 4.7, "total": 400, "color": const Color(0xFFC2410C)},
    {"title": "Sapiens", "author": "Yuval Noah Harari", "rating": 4.9, "total": 512, "color": const Color(0xFFEAB308)},
    {"title": "Nguyên lý 80/20", "author": "Richard Koch", "rating": 4.5, "total": 300, "color": const Color(0xFF3B82F6)},
    {"title": "Dám bị ghét", "author": "Kishimi Ichiro", "rating": 4.8, "total": 350, "color": const Color(0xFF1E6F86)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTabSwitcher(),
                    const SizedBox(height: 24),

                    // Logic hiển thị theo Tab
                    if (_currentTab == 'reading')
                      _buildReadingListRealtime()
                    else
                      _buildDiscoveryList(),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. DANH SÁCH SÁCH TỪ FIREBASE (Sửa lỗi bấm không ăn tại đây) ---
  Widget _buildReadingListRealtime() {
    return StreamBuilder<List<BookModel>>(
      stream: DatabaseService().getBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              children: const [
                SizedBox(height: 40),
                Icon(Icons.library_books, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text("Tủ sách trống trơn", style: TextStyle(color: Colors.grey)),
                Text("Bấm dấu (+) để thêm sách nhé!", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }

        final books = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tủ sách (${books.length})", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 16),
            ...books.map((book) => _buildRealBookCard(book)),
          ],
        );
      },
    );
  }

  // Card sách thật
  Widget _buildRealBookCard(BookModel book) {
    double progress = book.totalPages > 0 ? (book.currentPage / book.totalPages) : 0;

    return GestureDetector(
      // --- SỬA LỖI: Đã thêm sự kiện bấm vào đây ---
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)), // Chuyển sang trang Chi tiết
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa
            Container(
              width: 70, height: 100,
              decoration: BoxDecoration(
                color: book.coverColor ?? AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: book.imageUrl.isNotEmpty
                    ? (book.imageUrl.startsWith('http')
                    ? Image.network(book.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.book, color: Colors.white))
                // Nếu là đường dẫn ảnh trong máy (khi test máy ảo có thể lỗi ảnh nhưng ko sao)
                    : const Center(child: Icon(Icons.image, color: Colors.white)))
                    : const Center(child: Icon(Icons.book, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 16),

            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Text(book.author, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade100, color: Colors.orange.shade600, minHeight: 6),
                  ),
                  const SizedBox(height: 12),
                  Text("${book.totalPages} trang", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- 2. CÁC WIDGET PHỤ (HEADER, TAB, DISCOVERY) ---

  Widget _buildDiscoveryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("✨ Gợi ý cho bạn", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _discoveryBooks.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) => _buildDiscoveryBookCard(_discoveryBooks[index]),
        ),
      ],
    );
  }

  Widget _buildDiscoveryBookCard(Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookPreviewScreen(book: book))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(color: book['color'], borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: Text(book['title'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(flex: 2, child: Center(child: Text(book['author'], style: const TextStyle(fontSize: 12, color: Colors.grey))))
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("CHÀO BUỔI TỐI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textGrey)), Text("Tiến Dũng", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark))]),
          const CircleAvatar(backgroundColor: AppColors.primary, child: Text("TD", style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Expanded(child: GestureDetector(onTap: () => setState(() => _currentTab = 'reading'), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: _currentTab == 'reading' ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text("Đang đọc", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))))),
        Expanded(child: GestureDetector(onTap: () => setState(() => _currentTab = 'discovery'), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: _currentTab == 'discovery' ? AppColors.amber : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text("Khám phá", style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold)))))),
      ]),
    );
  }
}