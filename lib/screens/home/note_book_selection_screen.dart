import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/database_service.dart';
import '../active_notes/book_notes_screen.dart'; // File vừa tạo ở bước 4

class NoteBookSelectionScreen extends StatelessWidget {
  const NoteBookSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chọn sách để ghi chú")),
      body: StreamBuilder<List<BookModel>>(
        stream: DatabaseService().getBooks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final books = snapshot.data ?? [];
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                leading: book.imageUrl.isNotEmpty
                    ? Image.network(book.imageUrl, width: 40, fit: BoxFit.cover)
                    : const Icon(Icons.book),
                title: Text(book.title),
                subtitle: Text("Đang ở trang ${book.currentPage}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Chuyển sang màn hình Ghi chú Chủ động của cuốn sách này
                  Navigator.push(context, MaterialPageRoute(builder: (_) => BookNotesScreen(book: book)));
                },
              );
            },
          );
        },
      ),
    );
  }
}