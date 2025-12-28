import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
    returnImage: false,
  );

  bool _isScanned = false;
  bool _isFlashOn = false; // Biến tự quản lý trạng thái đèn Flash

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Hàm xử lý khi quét (hoặc khi bấm nút giả lập)
  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code != null) {
      setState(() => _isScanned = true);

      // Giả lập tìm thấy sách
      final foundBook = BookModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Sách tìm thấy",
        author: "Mã vạch: $code",
        description: "Đây là cuốn sách được tìm thấy thông qua quét mã vạch ISBN.",
        content: "",
        totalPages: 300,
        imageUrl: "",
        colorValue: [0xFFC2410C, 0xFF1E6F86, 0xFFEAB308, 0xFF3B82F6][Random().nextInt(4)],
        createdAt: DateTime.now(),
        rating: 4.5,
        reviewsCount: 10,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BookAddPreviewScreen(book: foundBook)),
      );
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
            onDetect: _onDetect,
          ),

          // Lớp phủ mờ
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcOut),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 280, height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Khung viền đỏ
          Center(
            child: Container(
              width: 280, height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 260, height: 1, color: Colors.red.withOpacity(0.5),
              ),
            ),
          ),

          // Nút Back & Flash
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white, size: 28
                        ),
                        onPressed: () async {
                          await _controller.toggleTorch();
                          setState(() {
                            _isFlashOn = !_isFlashOn;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    "Di chuyển camera vào mã vạch",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // --- NÚT GIẢ LẬP QUÉT (Dành cho máy ảo) ---
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              icon: const Icon(Icons.bug_report, color: Colors.white),
              label: const Text("Giả lập (Máy ảo)", style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Giả vờ như camera vừa quét được mã 978...
                _onDetect(BarcodeCapture(
                  barcodes: [Barcode(rawValue: '9786047726359')],
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}