import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Tạo hiệu ứng dòng quét chạy đi chạy lại
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // 1. Header: Tiêu đề và nút Đóng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Placeholder để cân giữa
                  const Text(
                    "Quét QR",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark
                    ),
                  ),
                  // Nút đóng (X)
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B), // Màu nền tối cho nút X giống ảnh
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 40),

              // 2. Khung Camera giả lập
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Nền đen (Giả lập camera)
                      Container(
                        width: 300,
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.black, width: 8), // Viền đen dày
                        ),
                        // Sau này nhúng CameraPreview vào đây
                      ),

                      // Khung viền màu cam 4 góc (Trang trí)
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      // 4 Góc màu cam (Dùng Stack nhỏ để vẽ)
                      Positioned(top: 60, left: 20, child: _buildCorner(0)),
                      Positioned(top: 60, right: 20, child: _buildCorner(1)),
                      Positioned(bottom: 60, left: 20, child: _buildCorner(2)),
                      Positioned(bottom: 60, right: 20, child: _buildCorner(3)),

                      // Dòng quét chạy lên xuống (Animation)
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 100 * (_controller.value - 0.5) * 2),
                            child: Container(
                              width: 240,
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
                    ],
                  ),
                ),
              ),

              // 3. Dòng chữ hướng dẫn bên dưới
              const Text(
                "Di chuyển camera đến mã QR",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm vẽ 4 góc màu cam (Trang trí cho giống Figma)
  Widget _buildCorner(int rotateQuarters) {
    return RotatedBox(
      quarterTurns: rotateQuarters,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.amber, width: 4),
            left: BorderSide(color: AppColors.amber, width: 4),
          ),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12)),
        ),
      ),
    );
  }
}