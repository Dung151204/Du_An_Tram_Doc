import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../services/database_service.dart';
import 'manual_add_screen.dart';
// import 'book_add_preview_screen.dart'; // Có thể bỏ nếu không cần xem trước khi clone

class SearchAddScreen extends StatefulWidget {
  const SearchAddScreen({super.key});

  @override
  State<SearchAddScreen> createState() => _SearchAddScreenState();
}

class _SearchAddScreenState extends State<SearchAddScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _keyword = "";

  // [HÀM MỚI] Xử lý khi bấm dấu Cộng (+) để Clone sách
  void _onAddToLibrary(BookModel book) async {
    try {
      // Gọi service để Clone sách về tủ cá nhân
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
                  hintText: "Nhập tên sách, tác giả...",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.orange),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),

          if (_keyword.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                "Gợi ý từ Kho chung", // Sửa text cho hợp logic
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ),

          // DANH SÁCH KẾT QUẢ
          Expanded(
            child: StreamBuilder<List<BookModel>>(
              // [QUAN TRỌNG] Đổi thành getPublicBooks để chỉ tìm trong KHO CHUNG
              stream: DatabaseService().getPublicBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final allBooks = snapshot.data ?? [];

                // Logic lọc tìm kiếm (giữ nguyên)
                List<BookModel> displayBooks = [];
                if (_keyword.isEmpty) {
                  // Sắp xếp theo rating nếu chưa tìm gì
                  allBooks.sort((a, b) => b.rating.compareTo(a.rating));
                  displayBooks = allBooks.take(10).toList();
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
                        const Icon(Icons.search_off, size: 50, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(_keyword.isEmpty ? "Kho sách trống" : "Không tìm thấy: \"$_keyword\"", style: const TextStyle(color: Colors.grey)),
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
    Color avatarColor = book.coverColor?.withOpacity(0.2) ?? Colors.orange.shade100;
    Color letterColor = book.coverColor ?? Colors.orange;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: avatarColor, borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.center,
          child: Text(firstLetter, style: TextStyle(color: letterColor, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(book.author, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ),
        // [LOGIC NÚT ADD]
        trailing: GestureDetector(
          onTap: () {
            // Thay vì chuyển màn hình, ta gọi hàm Clone ngay lập tức
            _onAddToLibrary(book);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}