import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../services/database_service.dart';
import 'manual_add_screen.dart';

class SearchAddScreen extends StatefulWidget {
  const SearchAddScreen({super.key});

  @override
  State<SearchAddScreen> createState() => _SearchAddScreenState();
}

class _SearchAddScreenState extends State<SearchAddScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _keyword = "";

  // Xử lý khi bấm dấu Cộng (+) để Clone sách
  void _onAddToLibrary(BookModel book) async {
    try {
      await DatabaseService().cloneBookToLibrary(book);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đã thêm '${book.title}' vào tủ sách cá nhân!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Thêm sách",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. THANH TÌM KIẾM
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _keyword = value.toLowerCase().trim()),
                decoration: const InputDecoration(
                  hintText: "Tìm trong Tủ chung...",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.orange),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),

          // 2. TIÊU ĐỀ MỤC
          if (_keyword.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                "Tủ sách chung",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ),

          // 3. DANH SÁCH KẾT QUẢ
          Expanded(
            child: StreamBuilder<List<BookModel>>(
              stream: DatabaseService().getPublicBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final allBooks = snapshot.data ?? [];

                // Logic lọc và sắp xếp
                List<BookModel> displayBooks = [];
                if (_keyword.isEmpty) {
                  allBooks.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
                  displayBooks = allBooks.take(20).toList();
                } else {
                  displayBooks = allBooks.where((book) =>
                  book.title.toLowerCase().contains(_keyword) ||
                      book.author.toLowerCase().contains(_keyword)
                  ).toList();
                }

                if (displayBooks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.library_books_outlined, size: 50, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                            _keyword.isEmpty ? "Tủ sách chung đang trống" : "Không tìm thấy: \"$_keyword\"",
                            style: const TextStyle(color: Colors.grey)
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayBooks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildBookItem(displayBooks[index]),
                );
              },
            ),
          ),

          // 4. NÚT NHẬP THỦ CÔNG
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ManualAddScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade50,
                  foregroundColor: Colors.orange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.edit_note),
                label: const Text("Nhập thủ công", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBookItem(BookModel book) {
    String firstLetter = book.title.isNotEmpty ? book.title[0].toUpperCase() : "?";
    // [FIX] Sửa withOpacity thành withValues
    Color avatarColor = book.coverColor?.withValues(alpha: 0.2) ?? Colors.orange.shade100;
    Color letterColor = book.coverColor ?? Colors.orange;

    String ratingText = (book.rating ?? 0.0).toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // [FIX] Sửa withOpacity thành withValues
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 50, height: 60,
              decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(12)
              ),
              alignment: Alignment.center,
              child: Text(
                  firstLetter,
                  style: TextStyle(color: letterColor, fontWeight: FontWeight.bold, fontSize: 22)
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      book.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 4),
                  Text(
                      book.author,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        ratingText,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  )
                ],
              ),
            ),

            GestureDetector(
              onTap: () => _onAddToLibrary(book),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}