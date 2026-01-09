import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http; // QUAN TRỌNG: Thư viện tải mạng
import '../../models/book_model.dart';

class SmartReadingScreen extends StatefulWidget {
  final BookModel book;
  const SmartReadingScreen({super.key, required this.book});

  @override
  State<SmartReadingScreen> createState() => _SmartReadingScreenState();
}

class _SmartReadingScreenState extends State<SmartReadingScreen> {
  String? _localPdfPath; // Đường dẫn file sau khi tải xong

  late PageController _textPageController;
  List<String> _textPages = [];

  bool _isLoading = true;
  bool _isPdfMode = false;
  int _currentPage = 0;
  int _totalPages = 0;
  String _statusMessage = "Đang kiểm tra dữ liệu...";

  @override
  void initState() {
    super.initState();
    _checkAndPrepareContent();
  }

  Future<void> _checkAndPrepareContent() async {
    String? path = widget.book.assetPath;

    // --- TRƯỜNG HỢP 1: LINK MẠNG (HTTP/HTTPS) ---
    if (path != null && (path.startsWith('http') || path.startsWith('https'))) {
      _isPdfMode = true;
      setState(() => _statusMessage = "Đang tải sách từ Server...");

      try {
        // 1. Tải dữ liệu từ URL
        final response = await http.get(Uri.parse(path));

        if (response.statusCode == 200) {
          // 2. Lưu vào bộ nhớ tạm của điện thoại
          final Directory tempDir = await getTemporaryDirectory();
          final File tempFile = File('${tempDir.path}/temp_book_${DateTime.now().millisecondsSinceEpoch}.pdf');

          await tempFile.writeAsBytes(response.bodyBytes);

          if (mounted) {
            setState(() {
              _localPdfPath = tempFile.path; // Đã có file thật trong máy
              _isLoading = false;
            });
          }
        } else {
          // Lỗi do Server (ví dụ 404 Not Found)
          _handleError("Không tải được sách. Lỗi Server: ${response.statusCode}");
        }
      } catch (e) {
        // Lỗi do mạng hoặc code
        _handleError("Lỗi kết nối: $e");
      }
    }

    // --- TRƯỜNG HỢP 2: FILE CÓ SẴN TRONG APP (ASSETS) ---
    else if (path != null && path.endsWith('.pdf')) {
      _isPdfMode = true;
      setState(() => _statusMessage = "Đang mở sách...");
      try {
        final ByteData data = await rootBundle.load(path);
        final Directory tempDir = await getTemporaryDirectory();
        final File tempFile = File('${tempDir.path}/${widget.book.title}.pdf');
        await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

        if (mounted) {
          setState(() {
            _localPdfPath = tempFile.path;
            _isLoading = false;
          });
        }
      } catch (e) {
        _isPdfMode = false;
        _processTextContent(); // Nếu lỗi PDF thì chuyển sang đọc chữ
      }
    }

    // --- TRƯỜNG HỢP 3: SÁCH CHỈ CÓ CHỮ (NHẬP TAY) ---
    else {
      _isPdfMode = false;
      _textPageController = PageController();
      _processTextContent();
    }
  }

  void _handleError(String error) {
    print(error);
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isPdfMode = false; // Chuyển về chế độ đọc text báo lỗi
        _statusMessage = error;
      });
      _processTextContent();
    }
  }

  // Hàm cắt chữ thành trang (cho sách nhập tay hoặc khi lỗi PDF)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isPdfMode ? Colors.white : const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: Text(widget.book.title, style: const TextStyle(fontSize: 16, color: Colors.black)),
        backgroundColor: _isPdfMode ? Colors.white : const Color(0xFFFFFBF0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
          ? PDFView(
        filePath: _localPdfPath,
        enableSwipe: true,
        swipeHorizontal: true,
        pageFling: true,
        onError: (error) {
          setState(() {
            _isLoading = false;
            _isPdfMode = false;
            _statusMessage = "File PDF bị lỗi: $error";
          });
        },
      )
          : PageView.builder(
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
      ),
    );
  }
}