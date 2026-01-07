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
    if (widget.book.assetPath == null) return;

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
          : _localFilePath == null
          ? const Center(child: Text("Lỗi: Không tìm thấy file PDF"))
          : PDFView(
        filePath: _localFilePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: true,
        onRender: (pages) => setState(() => _totalPages = pages ?? 0),
        onPageChanged: (page, total) => setState(() => _currentPage = page ?? 0),
        onError: (error) => print(error.toString()),
        onPageError: (page, error) => print('$page: ${error.toString()}'),
      ),
    );
  }
}