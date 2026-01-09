import 'dart:io';
import 'dart:typed_data'; // Cần thiết cho ByteData
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Cần thiết cho rootBundle
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import '../../models/book_model.dart';

// Giả định bạn có các file service này, nếu chưa import hãy bỏ comment và chỉnh đường dẫn đúng
// import '../../services/ai_service.dart';
// import '../../services/database_service.dart';

// --- MOCK SERVICE (Để code không báo lỗi nếu bạn chưa import file service thật) ---
// Bạn hãy xóa 2 class giả này đi nếu đã có file service thật
class AIService {
  Future<List<Map<String, dynamic>>> generateFlashcards(BookModel book) async => [];
}
class DatabaseService {
  Future<void> saveAICreatedFlashcards(String id, List<Map<String, dynamic>> quiz) async {}
  Future<void> appendBookContent(String id, String content) async {}
}
// -------------------------------------------------------------------------------

class SmartReadingScreen extends StatefulWidget {
  final BookModel book;
  const SmartReadingScreen({super.key, required this.book});

  @override
  State<SmartReadingScreen> createState() => _SmartReadingScreenState();
}

class _SmartReadingScreenState extends State<SmartReadingScreen> {
  String? _localFilePath; // Đã đồng nhất tên biến
  late PageController _textPageController;
  List<String> _textPages = [];

  bool _isLoading = true;
  bool _isPdfMode = false;
  bool _isGeneratingAI = false; // Đã thêm biến này
  int _currentPage = 0;
  int _totalPages = 0;
  String _statusMessage = "Đang kiểm tra dữ liệu...";

  @override
  void initState() {
    super.initState();
    _textPageController = PageController();
    _checkAndPrepareContent();
  }

  @override
  void dispose() {
    _textPageController.dispose();
    super.dispose();
  }

  Future<void> _checkAndPrepareContent() async {
    String? path = widget.book.assetPath;

    // --- TRƯỜNG HỢP 1: LINK MẠNG HOẶC FILE ASSET (PDF) ---
    if (path != null && path.isNotEmpty && (path.endsWith('.pdf') || path.startsWith('http'))) {
      _isPdfMode = true;
      if (mounted) setState(() => _statusMessage = "Đang tải tài liệu...");

      await _preparePdf(path);
    }
    // --- TRƯỜNG HỢP 2: SÁCH CHỈ CÓ CHỮ (NHẬP TAY) ---
    else {
      _isPdfMode = false;
      _processTextContent();
    }
  }

  // Tách logic tải PDF ra thành hàm riêng chuẩn xác
  Future<void> _preparePdf(String path) async {
    try {
      // 1. Xử lý Link URL (Online)
      if (path.startsWith('http')) {
        // Fix link GitHub sang link Raw
        if (path.contains('github.com') && !path.contains('raw.githubusercontent.com')) {
          path = path.replaceFirst('github.com', 'raw.githubusercontent.com').replaceFirst('/blob/', '/');
        }

        final response = await http.get(Uri.parse(path));

        if (response.statusCode == 200) {
          final Directory tempDir = await getTemporaryDirectory();
          final File tempFile = File('${tempDir.path}/temp_book_${widget.book.id}.pdf');

          await tempFile.writeAsBytes(response.bodyBytes, flush: true);

          if (mounted) {
            setState(() {
              _localFilePath = tempFile.path;
              _isLoading = false;
            });
          }
        } else {
          _handleError("Lỗi Server: ${response.statusCode}");
        }
      }
      // 2. Xử lý Local Asset (Offline trong app)
      else {
        try {
          final ByteData data = await rootBundle.load(path);
          final Directory tempDir = await getTemporaryDirectory();
          final File tempFile = File('${tempDir.path}/${widget.book.id}_asset.pdf');

          await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

          if (mounted) {
            setState(() {
              _localFilePath = tempFile.path;
              _isLoading = false;
            });
          }
        } catch (e) {
          _handleError("Không tìm thấy file trong máy: $e");
        }
      }
    } catch (e) {
      _handleError("Lỗi kết nối hoặc ghi file: $e");
    }
  }

  // Hàm gọi AI (Sửa lại cấu trúc để không bị lồng sai)
  void _startAIReview() async {
    if (mounted) setState(() => _isGeneratingAI = true);

    try {
      final quiz = await AIService().generateFlashcards(widget.book);
      await DatabaseService().saveAICreatedFlashcards(widget.book.id!, quiz);

      if (mounted) {
        setState(() => _isGeneratingAI = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã tạo câu hỏi ôn tập thành công!")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingAI = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi AI: $e")),
        );
      }
    }
  }

  void _handleError(String error) {
    print("Error Log: $error");
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isPdfMode = false; // Chuyển về chế độ đọc text báo lỗi
        _statusMessage = error;
      });
      _processTextContent(); // Fallback về text view
    }
  }

  void _processTextContent() {
    String content = widget.book.content;
    if (content.isEmpty) {
      content = "⚠️ $_statusMessage \n\n(Nội dung sách trống hoặc không tải được PDF)";
    }

    int charsPerPage = 500;
    _textPages.clear();
    for (int i = 0; i < content.length; i += charsPerPage) {
      int end = (i + charsPerPage < content.length) ? i + charsPerPage : content.length;
      _textPages.add(content.substring(i, end).trim());
    }
    if (mounted) setState(() => _isLoading = false);
  }

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
                await DatabaseService().appendBookContent(widget.book.id!, _contentController.text.trim());
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Đã cập nhật nội dung mới!")),
                  );
                  // Refresh lại nội dung text nếu cần
                  setState(() {
                    // Cập nhật lại model book trong RAM nếu cần thiết
                    // widget.book.content += "\n" + _contentController.text.trim();
                    _processTextContent();
                  });
                }
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
      backgroundColor: _isPdfMode ? Colors.white : const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: Text(widget.book.title, style: const TextStyle(fontSize: 16, color: Colors.black)),
        backgroundColor: _isPdfMode ? Colors.white : const Color(0xFFFFFBF0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: _isGeneratingAI ? null : _startAIReview,
            tooltip: "Tạo câu hỏi AI",
          )
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_statusMessage, textAlign: TextAlign.center),
          ],
        ),
      )
          : _isPdfMode
          ? (_localFilePath != null
          ? PDFView(
        filePath: _localFilePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: true,
        onRender: (pages) => setState(() => _totalPages = pages ?? 0),
        onPageChanged: (page, total) => setState(() => _currentPage = page ?? 0),
        onError: (error) {
          _handleError(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
      )
          : const Center(child: Text("Lỗi tải file PDF")))
          : _textPages.isNotEmpty
          ? PageView.builder( // Ưu tiên hiển thị dạng trang nếu có dữ liệu phân trang
        controller: _textPageController,
        itemCount: _textPages.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: SingleChildScrollView(
              child: Text(
                _textPages[index],
                style: const TextStyle(fontSize: 18, height: 1.6, fontFamily: 'Roboto'),
                textAlign: TextAlign.justify,
              ),
            ),
          );
        },
        onPageChanged: (page) => setState(() => _currentPage = page),
      )
          : _buildTextView(), // Fallback nếu không chia trang được hoặc muốn nhập liệu
    );
  }

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