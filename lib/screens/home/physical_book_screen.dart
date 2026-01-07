import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/book_model.dart';
import '../../services/database_service.dart';

class PhysicalBookScreen extends StatelessWidget {
  const PhysicalBookScreen({super.key});

  // Dialog cập nhật vị trí (FR1.2)
  void _showLocationDialog(BuildContext context, BookModel book) {
    final locController = TextEditingController(text: book.physicalLocation);
    final lentController = TextEditingController(text: book.lentTo);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Vị trí: ${book.title}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: locController,
              decoration: const InputDecoration(labelText: "Vị trí (VD: Kệ phòng khách)", prefixIcon: Icon(Icons.location_on)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lentController,
              decoration: const InputDecoration(labelText: "Cho ai mượn (VD: Bạn Nam)", prefixIcon: Icon(Icons.person)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('books').doc(book.id).update({
                'physicalLocation': locController.text,
                'lentTo': lentController.text,
              });
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
        title: const Text("Quản lý Sách giấy", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: StreamBuilder<List<BookModel>>(
        stream: DatabaseService().getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final books = snapshot.data ?? [];

          if (books.isEmpty) return const Center(child: Text("Chưa có sách nào."));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            separatorBuilder: (_,__) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final book = books[index];
              final bool isLent = book.lentTo.isNotEmpty;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    // Icon trạng thái
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isLent ? Colors.red.shade50 : Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLent ? LucideIcons.userX : LucideIcons.mapPin,
                        color: isLent ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          if (isLent)
                            Text("Đang cho ${book.lentTo} mượn", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                          else if (book.physicalLocation.isNotEmpty)
                            Text("Tại: ${book.physicalLocation}", style: const TextStyle(color: Colors.green))
                          else
                            const Text("Chưa cập nhật vị trí", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showLocationDialog(context, book),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}