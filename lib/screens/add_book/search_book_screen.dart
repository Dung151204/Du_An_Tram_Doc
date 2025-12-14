import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';

class SearchBookScreen extends StatelessWidget {
  const SearchBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập
    final List<Map<String, dynamic>> results = [
      {"title": "Tư duy nhanh và chậm", "author": "Daniel Kahneman", "color": Colors.amber.shade100, "text": Colors.amber.shade900},
      {"title": "Tìm kiếm hợp tác", "author": "Nguyen Bam", "color": Colors.blue.shade100, "text": Colors.blue.shade900},
      {"title": "Không gian gia đình", "author": "Hector Malot", "color": Colors.red.shade100, "text": Colors.red.shade900},
      {"title": "Thích nhân tâm", "author": "Dale Carnegie", "color": Colors.purple.shade100, "text": Colors.purple.shade900},
      {"title": "Kỹ năng mềm", "author": "Nguyen Bam", "color": Colors.orange.shade100, "text": Colors.orange.shade900},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Nền xám rất nhạt
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppColors.textDark),
        title: const Text("Tìm kiếm", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. Thanh tìm kiếm
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ]
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Nhập tên sách, tác giả...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(LucideIcons.search, color: AppColors.textGrey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Danh sách kết quả
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final book = results[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        // Ảnh bìa giả lập (Màu vuông)
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: book['color'],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              book['title'][0], // Lấy chữ cái đầu
                              style: TextStyle(color: book['text'], fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Thông tin sách
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(book['author'], style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                            ],
                          ),
                        ),

                        // Nút (+) Tròn màu cam
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.orange, // AppColors.amber
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
                        )
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}