import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../reading/reading_screen.dart';
import 'rating_screen.dart'; // <--- 1. Đã thêm import màn hình đánh giá

class BookPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookPreviewScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. NỀN GRADIENT
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  book['color'] ?? const Color(0xFFC2410C),
                  Colors.white,
                ],
                stops: const [0.5, 0.9],
              ),
            ),
          ),

          // 2. NỘI DUNG
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      // Nút Back
                      _buildCircleButton(context, LucideIcons.chevronLeft, onTap: () => Navigator.pop(context)),

                      const Spacer(),

                      // --- 2. CẬP NHẬT NÚT NGÔI SAO TẠI ĐÂY ---
                      _buildCircleButton(
                        context,
                        LucideIcons.star,
                        onTap: () {
                          // Chuyển sang màn hình RatingScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RatingScreen(book: book)),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Ảnh bìa sách (Hero Animation)
                Hero(
                  tag: book['title'],
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: book['image'] != null
                          ? Image.asset(book['image'], width: 160, height: 240, fit: BoxFit.cover)
                          : Container(
                        width: 160, height: 240,
                        color: book['color'],
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: Text(book['title'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tên sách & Tác giả
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    book['title'],
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book['author'],
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),

                const SizedBox(height: 32),

                // 3 Thông số
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoChip("${book['rating']} ⭐"),
                    const SizedBox(width: 12),
                    _buildInfoChip("${book['total']} trang"),
                    const SizedBox(width: 12),
                    _buildInfoChip("Tâm lý"),
                  ],
                ),

                const Spacer(),

                // KHỐI CARD TRẮNG Ở DƯỚI
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tiến độ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tiến độ của bạn", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                          Text("0/${book['total']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // NÚT BẮT ĐẦU ĐỌC
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ReadingScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(LucideIcons.bookOpen, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Bắt đầu đọc", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCircleButton(BuildContext context, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
    );
  }
}