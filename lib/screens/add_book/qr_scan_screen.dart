import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import 'book_preview_screen.dart'; // Import màn hình Preview

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isScanning = true; // Trạng thái đang quét

  @override
  void initState() {
    super.initState();

    // 1. Hiệu ứng dòng quét chạy lên xuống
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // 2. GIẢ LẬP QUÉT THÀNH CÔNG SAU 2 GIÂY
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = false; // Dừng quét
        });

        // Chuyển sang màn hình Preview
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BookPreviewScreen(
              bookTitle: "Đắc Nhân Tâm", // Tên sách
              author: "Dale Carnegie",   // Tác giả
              // QUAN TRỌNG: Truyền đúng ảnh Đắc Nhân Tâm
              // (Nhớ đảm bảo bạn đã có file dac_nhan_tam.jpg trong assets/images)
              imagePath: "assets/images/dac_nhan_tam.jpg",
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Chỉnh màu thanh trạng thái thành trắng (Light) vì nền camera màu đen
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: Colors.black, // Nền đen giả lập Camera
      body: Stack(
        children: [
          // 1. Camera Preview (Giả lập bằng màu đen)
          Positioned.fill(
            child: Container(color: Colors.black),
          ),

          // 2. Khung quét và Hiệu ứng
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40), // Placeholder để cân giữa
                      const Text(
                        "Quét QR",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white // Chữ trắng trên nền đen
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  ),
                ),

                const Spacer(),

                // KHUNG QUÉT CHÍNH
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Viền 4 góc
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: Stack(
                          children: [
                            Positioned(top: 0, left: 0, child: _buildCorner(0)),
                            Positioned(top: 0, right: 0, child: _buildCorner(1)),
                            Positioned(bottom: 0, left: 0, child: _buildCorner(2)),
                            Positioned(bottom: 0, right: 0, child: _buildCorner(3)),
                          ],
                        ),
                      ),

                      // Dòng tia laser chạy
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 260 * (_controller.value - 1)), // Chạy trong khoảng khung
                            child: Container(
                              width: 260,
                              height: 2,
                              decoration: BoxDecoration(
                                color: AppColors.amber,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.amber.withOpacity(0.6),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Text thông báo trạng thái
                      if (!_isScanning)
                        const Center(
                          child: Icon(LucideIcons.checkCircle, color: Colors.green, size: 64),
                        )
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                const Text(
                  "Di chuyển camera đến mã vạch sách",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Spacer(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(int quarterTurns) {
    return RotatedBox(
      quarterTurns: quarterTurns,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.amber, width: 4),
            left: BorderSide(color: AppColors.amber, width: 4),
          ),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
        ),
      ),
    );
  }
}