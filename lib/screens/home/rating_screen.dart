import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';

class RatingScreen extends StatefulWidget {
  final Map<String, dynamic> book; // Nhận thông tin sách để hiển thị ảnh bìa

  const RatingScreen({super.key, required this.book});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0; // Biến lưu số sao người dùng chọn (0 -> 5)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Đánh giá sách",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: const Icon(LucideIcons.chevronLeft, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 1. ẢNH BÌA SÁCH
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.book['image'],
                  width: 120,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. TÊN SÁCH & TÁC GIẢ
            Text(
              widget.book['title'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.book['author'],
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // 3. HÀNG 5 NGÔI SAO (Tương tác được)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1; // Bấm sao thứ 3 thì rating = 3
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star_rounded : LucideIcons.star, // Đã chọn thì full, chưa thì rỗng
                    color: index < _rating ? Colors.amber : Colors.grey.shade400,
                    size: 32,
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // 4. Ô NHẬP LIỆU (Màu xanh nhạt)
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // Màu xanh dương rất nhạt (giống ảnh)
                borderRadius: BorderRadius.circular(16),
              ),
              child: const TextField(
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Bạn cảm thấy cuốn sách này thế nào ?\nChia sẻ suy nghĩ của bạn nhé...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 5. NÚT GỬI ĐÁNH GIÁ
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý gửi đánh giá (hiện tại chỉ back về)
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã gửi đánh giá thành công!"), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF6FF), // Nền xanh nhạt
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(LucideIcons.send, color: Colors.grey, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Gửi đánh giá",
                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}