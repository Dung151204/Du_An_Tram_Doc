import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../services/database_service.dart';
import 'book_add_preview_screen.dart';
import 'manual_add_screen.dart';

class SearchAddScreen extends StatefulWidget {
  const SearchAddScreen({super.key});

  @override
  State<SearchAddScreen> createState() => _SearchAddScreenState();
}

class _SearchAddScreenState extends State<SearchAddScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _keyword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("Tìm sách có sẵn", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _keyword = value.toLowerCase().trim()),
                decoration: const InputDecoration(
                  hintText: "Nhập tên sách hoặc tác giả...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<BookModel>>(
              stream: DatabaseService().getBooks(), // Kết nối Firebase thật
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                final allBooks = snapshot.data ?? [];

                // Nếu kho sách rỗng
                if (allBooks.isEmpty) {
                  return const Center(child: Text("Kho sách chung chưa có dữ liệu.\nHãy là người đầu tiên đóng góp!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)));
                }

                List<BookModel> displayBooks = [];

                if (_keyword.isEmpty) {
                  // Đề xuất 5 cuốn có Rating cao nhất
                  allBooks.sort((a, b) => b.rating.compareTo(a.rating));
                  displayBooks = allBooks.take(5).toList();
                } else {
                  // Tìm kiếm theo tên (Không phân biệt hoa thường)
                  displayBooks = allBooks.where((book) =>
                  book.title.toLowerCase().contains(_keyword) ||
                      book.author.toLowerCase().contains(_keyword)
                  ).toList();
                }

                if (displayBooks.isEmpty) {
                  return Column(
                    children: [
                      const SizedBox(height: 50),
                      const Icon(Icons.search_off, size: 50, color: Colors.grey),
                      Text("Không tìm thấy sách: \"$_keyword\"", style: const TextStyle(color: Colors.grey)),
                    ],
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

          // Nút nhập thủ công
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit_note, color: Colors.white),
              label: const Text("Không tìm thấy? Nhập thủ công", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManualAddScreen()),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBookItem(BookModel book) {
    String firstLetter = book.title.isNotEmpty ? book.title[0].toUpperCase() : "?";
    Color avatarColor = book.coverColor?.withOpacity(0.2) ?? Colors.orange.shade100;
    Color letterColor = book.coverColor ?? Colors.orange;

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: avatarColor, borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.center,
          child: Text(firstLetter, style: TextStyle(color: letterColor, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            Text(book.author, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(width: 8),
            // Hiển thị sao đánh giá
            Icon(Icons.star, size: 14, color: Colors.amber),
            Text(" ${book.rating}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookAddPreviewScreen(book: book)));
          },
          child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 20)),
        ),
      ),
    );
  }
}