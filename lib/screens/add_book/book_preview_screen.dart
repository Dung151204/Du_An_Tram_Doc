import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- 1. QUAN TRỌNG: Thêm thư viện này
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';

class BookPreviewScreen extends StatelessWidget {
  final String bookTitle;
  final String author;

  const BookPreviewScreen({
    super.key,
    required this.bookTitle,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    // 2. LỆNH ĐỔI MÀU ICON THANH TRẠNG THÁI SANG MÀU ĐEN (DARK)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Nền xám nhạt
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Đảm bảo icon status bar luôn đen khi có AppBar
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.textDark, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 300,
          height: 580,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // --- CARD THÔNG TIN (MÀU KEM) ---
              Container(
                height: 450,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF8E7), // Màu kem
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 180), // Khoảng trống né ảnh bìa

                    // Tên sách
                    Text(
                      bookTitle.isEmpty ? "Nhà Giả Kim" : bookTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Tác giả
                    Text(
                      author.isEmpty ? "Paulo Coelho" : author,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF3B82F6), // Xanh dương
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Số trang
                    const Text(
                      "304 trang",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    // Nút Thêm sách
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () {
                          // Quay về màn hình chính
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text(
                          "Thêm sách",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // --- ẢNH BÌA SÁCH ---
              Positioned(
                top: 0,
                child: Container(
                  width: 180,
                  height: 270,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/nha_gia_kim.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                            color: Colors.grey.shade300,
                            child: const Center(child: Icon(LucideIcons.image, size: 50, color: Colors.grey))
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}