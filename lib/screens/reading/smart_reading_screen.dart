import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../models/book_model.dart';
import '../../services/database_service.dart';
import '../../services/ai_service.dart';

class SmartReadingScreen extends StatefulWidget {
  final BookModel book;
  const SmartReadingScreen({super.key, required this.book});

  @override
  State<SmartReadingScreen> createState() => _SmartReadingScreenState();
}

class _SmartReadingScreenState extends State<SmartReadingScreen> {
  String? _localFilePath;
  bool _isLoading = true;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isGeneratingAI = false;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  // Copy file từ Assets ra thư mục tạm trên điện thoại để đọc
  Future<void> _preparePdf() async {
    if (widget.book.assetPath == null) {
      // Nếu không có PDF thì vẫn phải tắt loading để hiện trình đọc Text
      setState(() => _isLoading = false);
      return;
    }

    try {
      final ByteData data = await rootBundle.load(widget.book.assetPath!);
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/${widget.book.title}.pdf');

      await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

      if (mounted) {
        setState(() {
          _localFilePath = tempFile.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi đọc PDF: $e");
      setState(() => _isLoading = false);
    }
  }

  // Gọi AI tạo câu hỏi ôn tập
  void _startAIReview() async {
    setState(() => _isGeneratingAI = true);

    // Mẹo Demo: Vì PDF là ảnh, ta gửi nội dung text tóm tắt có sẵn cho AI
    String contextText = widget.book.content.isNotEmpty
        ? widget.book.content
        : "Nội dung cuốn sách ${widget.book.title} của tác giả ${widget.book.author}.";

    try {
      // Gọi AI Service
      final quiz = await AIService().generateFlashcards(widget.book);

      // Lưu vào Firebase
      await DatabaseService().saveAICreatedFlashcards(widget.book.id!, quiz);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ AI đã tạo bộ câu hỏi! Vào mục 'Ôn tập' để xem.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi AI: $e")));
      }
    }

    setState(() => _isGeneratingAI = false);
  }

  // --- HÀM THÊM: DIALOG NHẬP NỘI DUNG (GIỮ NGUYÊN LOGIC MERGE) ---
  void _showAddContentDialog() {
    final TextEditingController _contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tiếp tục viết nội dung"),
        content: TextField(
          controller: _contentController,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: "Dán nội dung mới vào đây...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (_contentController.text.trim().isNotEmpty) {
                // Gọi hàm appendBookContent trong DatabaseService (hàm này đã thêm ở file trước)
                await DatabaseService().appendBookContent(widget.book.id!, _contentController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Đã cập nhật nội dung mới!")),
                );
              }
            },
            child: const Text("Cập nhật"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: _isGeneratingAI
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.psychology, color: Colors.orange, size: 30),
            onPressed: _isGeneratingAI ? null : _startAIReview,
            tooltip: "AI Ôn tập",
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (widget.book.assetPath != null && _localFilePath != null)
          ? PDFView(
        filePath: _localFilePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: true,
        onRender: (pages) => setState(() => _totalPages = pages ?? 0),
        onPageChanged: (page, total) => setState(() => _currentPage = page ?? 0),
        onError: (error) => print(error.toString()),
        onPageError: (page, error) => print('$page: ${error.toString()}'),
      )
          : _buildTextView(), // Trình xem văn bản có nút thêm nội dung
    );
  }

  // --- WIDGET BỔ SUNG ĐỂ HIỂN THỊ NỘI DUNG TEXT VÀ NÚT THÊM ---
  Widget _buildTextView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            widget.book.content.isNotEmpty ? widget.book.content : "Sách chưa có nội dung văn bản.",
            style: const TextStyle(fontSize: 18, height: 1.6),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const Text("--- Hết ---", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          // NÚT THÊM NỘI DUNG MỚI
          ElevatedButton.icon(
            onPressed: _showAddContentDialog,
            icon: const Icon(Icons.add_comment),
            label: const Text("THÊM NỘI DUNG MỚI"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}