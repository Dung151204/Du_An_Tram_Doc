import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../services/database_service.dart';
import '../../main_wrapper.dart'; // <--- 1. NHỚ IMPORT FILE NÀY

class BookAddPreviewScreen extends StatefulWidget {
  final BookModel book;
  final File? imageFile;

  const BookAddPreviewScreen({
    super.key,
    required this.book,
    this.imageFile
  });

  @override
  State<BookAddPreviewScreen> createState() => _BookAddPreviewScreenState();
}

class _BookAddPreviewScreenState extends State<BookAddPreviewScreen> {
  bool _isLoading = false;

  Future<void> _saveToFirebase() async {
    setState(() => _isLoading = true);
    try {
      await DatabaseService().addBook(widget.book);

      if (mounted) {
        // --- 2. SỬA LOGIC ĐIỀU HƯỚNG TẠI ĐÂY ---
        // Chuyển thẳng về MainWrapper để nó tự load lại Tủ sách (Tab 0)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
              (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đã thêm vào tủ sách thành công!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 280,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.imageFile != null
                          ? Image.file(widget.imageFile!, height: 300, fit: BoxFit.cover)
                          : Container(
                        height: 300, width: 200,
                        color: widget.book.coverColor != null ? Color(widget.book.colorValue!) : Colors.orange,
                        child: const Icon(Icons.book, size: 80, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(widget.book.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Text(widget.book.author, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text("${widget.book.totalPages} trang", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 0),
                onPressed: _isLoading ? null : _saveToFirebase,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Thêm sách", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}