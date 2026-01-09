import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/book_model.dart';
import '../../services/database_service.dart';
import '../reading/physical_reading_tracker.dart'; // Import màn hình đọc sách giấy & AI

class PhysicalBookScreen extends StatefulWidget {
  const PhysicalBookScreen({super.key});

  @override
  State<PhysicalBookScreen> createState() => _PhysicalBookScreenState();
}

class _PhysicalBookScreenState extends State<PhysicalBookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Hàm gom nhóm sách theo vị trí (Kệ A, Kệ B...)
  Map<String, List<BookModel>> _groupBooksByLocation(List<BookModel> books) {
    final Map<String, List<BookModel>> grouped = {};
    for (var book in books) {
      if (book.lentTo.isNotEmpty) continue; // Bỏ qua sách đang cho mượn (để sang tab kia)

      String location = book.physicalLocation.isEmpty ? "Chưa xếp kệ" : book.physicalLocation;
      if (!grouped.containsKey(location)) {
        grouped[location] = [];
      }
      grouped[location]!.add(book);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Quản lý Sách giấy", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue[800],
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue[800],
          tabs: const [
            Tab(text: "Tủ sách tại gia"),
            Tab(text: "Sổ mượn/trả"),
          ],
        ),
      ),
      body: StreamBuilder<List<BookModel>>(
        stream: DatabaseService().getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          // --- LOGIC SỬA LỖI TẠI ĐÂY ---
          // Lọc bỏ sách clone từ Google Books (sách clone luôn có originalBookId)
          // Chỉ giữ lại sách thêm thủ công (originalBookId là null hoặc rỗng)
          final allBooks = (snapshot.data ?? []).where((b) {
            return b.originalBookId == null || b.originalBookId!.isEmpty;
          }).toList();

          // Tách danh sách từ dữ liệu đã lọc
          final lentBooks = allBooks.where((b) => b.lentTo.isNotEmpty).toList();
          final shelfBooksMap = _groupBooksByLocation(allBooks);

          return TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: KỆ SÁCH (Gom nhóm)
              _buildShelvesTab(shelfBooksMap),

              // TAB 2: SÁCH ĐANG CHO MƯỢN
              _buildLentTab(lentBooks),
            ],
          );
        },
      ),
    );
  }

  // --- GIAO DIỆN TAB 1: CÁC KỆ SÁCH ---
  Widget _buildShelvesTab(Map<String, List<BookModel>> groupedBooks) {
    if (groupedBooks.isEmpty) return _buildEmptyState("Chưa có sách nào trong tủ");

    return ListView(
      padding: const EdgeInsets.all(16),
      children: groupedBooks.entries.map((entry) {
        String shelfName = entry.key;
        List<BookModel> books = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề Kệ
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
              child: Row(
                children: [
                  const Icon(LucideIcons.library, size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Text(shelfName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const Spacer(),
                  Text("${books.length} cuốn", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

            // Danh sách sách trong kệ đó
            ...books.map((book) => _buildBookCard(book, isLent: false)),

            const SizedBox(height: 16),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }

  // --- GIAO DIỆN TAB 2: SÁCH CHO MƯỢN ---
  Widget _buildLentTab(List<BookModel> books) {
    if (books.isEmpty) return _buildEmptyState("Hiện không có ai mượn sách");

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return _buildBookCard(books[index], isLent: true);
      },
    );
  }

  // --- CARD SÁCH CHUNG ---
  Widget _buildBookCard(BookModel book, {required bool isLent}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Ảnh bìa
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: book.imageUrl.isNotEmpty
                  ? Image.network(book.imageUrl, width: 60, height: 90, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(width: 60, height: 90, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)))
                  : Container(width: 60, height: 90, color: Colors.grey[200], child: const Icon(Icons.book, color: Colors.grey)),
            ),
            const SizedBox(width: 16),

            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(book.author, style: const TextStyle(fontSize: 13, color: Colors.grey)),

                  const SizedBox(height: 8),
                  if (isLent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Text("Đang ở chỗ: ${book.lentTo}", style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  else
                  // Thanh tiến độ đọc
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: book.totalPages > 0 ? book.currentPage / book.totalPages : 0,
                          backgroundColor: Colors.grey[200],
                          color: Colors.green,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        const SizedBox(height: 4),
                        Text("Đã đọc ${book.currentPage}/${book.totalPages} trang", style: const TextStyle(fontSize: 11, color: Colors.green)),
                      ],
                    )
                ],
              ),
            ),

            // Nút hành động
            IconButton(
              icon: Icon(isLent ? LucideIcons.userCheck : LucideIcons.playCircle,
                  color: isLent ? Colors.orange : Colors.blue, size: 32),
              onPressed: () {
                if (isLent) {
                  // Logic trả sách (Cập nhật lentTo = rỗng)
                  _showReturnDialog(book);
                } else {
                  // Logic Đọc & AI (Chuyển sang màn hình Tracker)
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PhysicalReadingTracker(book: book)));
                }
              },
            )
          ],
        ),
      ),
    );
  }

  // Dialog trả sách
  void _showReturnDialog(BookModel book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận trả sách"),
        content: Text("${book.lentTo} đã trả lại cuốn '${book.title}' rồi phải không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Chưa")),
          ElevatedButton(
            onPressed: () {
              DatabaseService().updateBook(book.id!, {'lentTo': ''}); // Xóa người mượn
              Navigator.pop(ctx);
            },
            child: const Text("Đúng, đã trả"),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.library, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}