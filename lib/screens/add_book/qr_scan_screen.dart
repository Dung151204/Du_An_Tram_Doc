import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import 'book_add_preview_screen.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;
  bool _isFlashOn = false; // [SỬA] Dùng biến này để quản lý đèn Flash

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchBookDetails(String isbn) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🔍 Đang tìm thông tin sách..."),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['totalItems'] != null && data['totalItems'] > 0) {
          final bookInfo = data['items'][0]['volumeInfo'];

          String title = bookInfo['title'] ?? "Không rõ tên";
          String author = "Không rõ tác giả";
          if (bookInfo['authors'] != null && (bookInfo['authors'] as List).isNotEmpty) {
            author = bookInfo['authors'][0];
          }
          String description = bookInfo['description'] ?? "Chưa có mô tả";
          int pageCount = bookInfo['pageCount'] ?? 0;

          String imageUrl = "";
          if (bookInfo['imageLinks'] != null) {
            imageUrl = bookInfo['imageLinks']['thumbnail'] ??
                bookInfo['imageLinks']['smallThumbnail'] ?? "";
            imageUrl = imageUrl.replaceFirst("http://", "https://");
          }

          final newBook = BookModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            author: author,
            description: description,
            content: "",
            totalPages: pageCount,
            imageUrl: imageUrl,
            rating: 5.0,
            reviewsCount: 0,
            createdAt: DateTime.now(),
            readingStatus: 'wishlist',
            keyTakeaways: [],
            isPublic: true,
          );

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BookAddPreviewScreen(book: newBook),
              ),
            );
          }
        } else {
          throw Exception("Không tìm thấy sách này.");
        }
      } else {
        throw Exception("Lỗi kết nối máy chủ.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Lỗi: ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: Colors.red,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isProcessing = false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_isProcessing) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && barcode.rawValue!.length >= 10) {
                  _fetchBookDetails(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          _buildOverlay(context),
          Positioned(
            top: 50, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // [SỬA] Nút Flash thủ công
                CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _controller.toggleTorch();
                      setState(() => _isFlashOn = !_isFlashOn);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 80, left: 0, right: 0,
            child: Column(
              children: [
                Text("Quét mã vạch (ISBN) phía sau sách",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    // ... Giữ nguyên phần UI Overlay
    double scanW = 300; double scanH = 150;
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.srcOut),
          child: Stack(
            children: [
              Container(decoration: const BoxDecoration(color: Colors.transparent, backgroundBlendMode: BlendMode.dstOut)),
              Center(child: Container(height: scanH, width: scanW, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)))),
            ],
          ),
        ),
        Center(child: Container(height: scanH, width: scanW, decoration: BoxDecoration(border: Border.all(color: AppColors.primary, width: 2), borderRadius: BorderRadius.circular(16)), child: Center(child: Container(height: 1, width: scanW - 20, color: Colors.red.withOpacity(0.8))))),
      ],
    );
  }
}