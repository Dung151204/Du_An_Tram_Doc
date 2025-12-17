import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';

class BookPreviewScreen extends StatelessWidget {
  final String bookTitle;
  final String author;
  final String imagePath; // <--- 1. Thêm biến này để nhận đường dẫn ảnh

  const BookPreviewScreen({
    super.key,
    required this.bookTitle,
    required this.author,
    required this.imagePath, // <--- 2. Bắt buộc truyền ảnh vào
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              // --- CARD THÔNG TIN ---
              Container(
                height: 450,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF8E7),
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
                    const SizedBox(height: 180),

                    // Tên sách
                    Text(
                      bookTitle.isEmpty ? "Chưa có tên" : bookTitle,
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
                      author.isEmpty ? "Chưa rõ" : author,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF3B82F6),
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
                      imagePath, // <--- 3. Dùng biến imagePath thay vì code cứng
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