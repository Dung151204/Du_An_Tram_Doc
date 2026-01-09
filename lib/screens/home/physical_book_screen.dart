import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần thêm package intl trong pubspec.yaml
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // [QUAN TRỌNG] Đã thêm dòng này để sửa lỗi Timestamp

import '../../models/book_model.dart';
import '../../services/database_service.dart';
import '../book_details/book_detail_screen.dart';

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

  // --- HÀM XỬ LÝ CHO MƯỢN SÁCH ---
  void _showLendDialog(BuildContext context, BookModel book) {
    final nameController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7)); // Mặc định trả sau 7 ngày

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Cho mượn sách"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Sách: ${book.title}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Tên người mượn",
                      prefixIcon: Icon(LucideIcons.user),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text("Ngày trả dự kiến"),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                    trailing: const Icon(LucideIcons.calendar),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setStateDialog(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isNotEmpty) {
                      // Tạo dữ liệu cập nhật
                      Map<String, dynamic> updateData = {
                        'lentTo': nameController.text.trim(),
                        // Giờ máy đã hiểu Timestamp là gì nhờ dòng import trên cùng
                        'returnDate': Timestamp.fromDate(selectedDate),
                      };

                      // Gọi Firebase cập nhật
                      await DatabaseService().updateBook(book.id!, updateData);

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Đã ghi nhận ${nameController.text} mượn sách")),
                      );
                    }
                  },
                  child: const Text("Xác nhận"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- HÀM XỬ LÝ TRẢ SÁCH ---
  void _returnBook(BookModel book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận trả sách"),
        content: Text("Người mượn '${book.lentTo}' đã trả lại cuốn sách này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Chưa")),
          ElevatedButton(
            onPressed: () async {
              // Xóa thông tin mượn (set về rỗng và null)
              await DatabaseService().updateBook(book.id!, {
                'lentTo': '',
                'returnDate': null,
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text("Sách đã được trả về kệ")),
              );
            },
            child: const Text("Đã trả"),
          )
        ],
      ),
    );
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
        // Lấy danh sách sách cá nhân từ Firebase
        stream: DatabaseService().getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final allBooks = snapshot.data ?? [];

          // Lọc danh sách:
          // 1. lentTo có chữ -> Đang cho mượn
          final lentBooks = allBooks.where((b) => b.lentTo.isNotEmpty).toList();
          // 2. lentTo rỗng -> Đang trên kệ
          final shelfBooks = allBooks.where((b) => b.lentTo.isEmpty).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildShelfList(shelfBooks),
              _buildLentList(lentBooks),
            ],
          );
        },
      ),
    );
  }

  // --- TAB 1: SÁCH TRÊN KỆ ---
  Widget _buildShelfList(List<BookModel> books) {
    if (books.isEmpty) return _buildEmptyState("Tủ sách trống, hãy thêm sách mới!");

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              // Bấm vào xem chi tiết
              Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)));
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildBookImage(book),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(book.author, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        // Hiển thị vị trí kệ (Ví dụ: Kệ A, Ngăn 2...)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            book.physicalLocation.isEmpty ? "Chưa xếp vị trí" : book.physicalLocation,
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Nút cho mượn
                  IconButton(
                    icon: const Icon(LucideIcons.arrowUpRight, color: Colors.orange),
                    tooltip: "Cho mượn",
                    onPressed: () => _showLendDialog(context, book),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- TAB 2: SÁCH ĐANG CHO MƯỢN ---
  Widget _buildLentList(List<BookModel> books) {
    if (books.isEmpty) return _buildEmptyState("Hiện không có ai mượn sách");

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        // Kiểm tra quá hạn
        final isOverdue = book.returnDate != null && DateTime.now().isAfter(book.returnDate!);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildBookImage(book),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.user, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("Người mượn: ${book.lentTo}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (book.returnDate != null)
                        Text(
                          "Hạn trả: ${DateFormat('dd/MM/yyyy').format(book.returnDate!)}",
                          style: TextStyle(
                              color: isOverdue ? Colors.red : Colors.green,
                              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12
                          ),
                        ),
                      if (isOverdue)
                        const Text("(Đã quá hạn!)", style: TextStyle(color: Colors.red, fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                // Nút báo đã trả
                IconButton(
                  icon: const Icon(LucideIcons.checkCircle, color: Colors.green, size: 28),
                  tooltip: "Đã trả sách",
                  onPressed: () => _returnBook(book),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookImage(BookModel book) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: book.imageUrl.isNotEmpty
          ? (book.imageUrl.startsWith('http')
          ? Image.network(book.imageUrl, width: 50, height: 75, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey[200]))
          : Image.file(File(book.imageUrl), width: 50, height: 75, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey[200])))
          : Container(width: 50, height: 75, color: Colors.grey[200], child: const Icon(Icons.book, color: Colors.grey)),
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