import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/book_model.dart';
import '../../models/review_model.dart';
import '../../services/database_service.dart';

class RatingScreen extends StatefulWidget {
  final BookModel book;

  const RatingScreen({super.key, required this.book});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _currentRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  // Màu sắc lấy từ thiết kế Figma
  final Color _kBgColor = const Color(0xFFF8F9FD); // Màu nền tổng thể hơi xám xanh nhẹ
  final Color _kInputColor = const Color(0xFFEAF4F8); // Màu xanh nhạt của ô input và nút
  final Color _kTextColor = const Color(0xFF1E293B); // Màu chữ đen xám

  void _setRating(int rating) {
    setState(() => _currentRating = rating.toDouble());
  }

  Future<void> _submitReview() async {
    if (_currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chạm vào sao để chấm điểm!")));
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hãy viết vài dòng cảm nhận nhé!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      final newReview = ReviewModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookId: widget.book.id ?? "unknown",
        userId: user?.uid ?? "guest",
        userName: user?.displayName ?? "Người dùng ẩn danh",
        rating: _currentRating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await DatabaseService().addReview(newReview, widget.book);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Đã gửi đánh giá thành công!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng sạch
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Đánh giá sách", style: TextStyle(color: _kTextColor, fontWeight: FontWeight.w800, fontSize: 18)),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFF1F5F9), // Nền tròn màu xám nhạt
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 1. ẢNH BÌA (Đổ bóng màu cam như Figma)
            Center(
              child: Container(
                height: 160, width: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.25), // Bóng cam
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: widget.book.imageUrl.isNotEmpty
                      ? (widget.book.imageUrl.startsWith('http')
                      ? Image.network(widget.book.imageUrl, fit: BoxFit.cover)
                      : Image.file(File(widget.book.imageUrl), fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey[200])))
                      : Container(color: Colors.grey[200], child: const Icon(Icons.book, size: 40, color: Colors.grey)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 2. TÊN SÁCH & TÁC GIẢ
            Text(widget.book.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _kTextColor), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(widget.book.author, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),

            const SizedBox(height: 24),

            // 3. HÀNG SAO (ICON VIỀN MỎNG)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => _setRating(index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      index < _currentRating ? Icons.star_rounded : Icons.star_outline_rounded, // Sao tròn
                      color: index < _currentRating ? const Color(0xFFFFB800) : Colors.grey.shade400, // Màu vàng đậm hơn chút
                      size: 36,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // 4. Ô NHẬP LIỆU (MÀU XANH NHẠT TO BẢN)
            Container(
              height: 140, // Cố định chiều cao cho giống cái hộp trong Figma
              decoration: BoxDecoration(
                color: _kInputColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _commentController,
                maxLines: null, // Cho phép xuống dòng thoải mái
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                decoration: const InputDecoration(
                  hintText: "Bạn cảm thấy cuốn sách này thế nào ?\nChia sẻ suy nghĩ của bạn nhé...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13, height: 1.6), // Chỉnh dòng height cho thoáng
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 5. NÚT GỬI (BO TRÒN, MÀU XANH NHẠT)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send_rounded, size: 20),
                label: const Text("Gửi đánh giá", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kInputColor, // Cùng màu với ô input
                  foregroundColor: const Color(0xFF475569), // Chữ màu xám xanh đậm
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _isLoading ? null : _submitReview,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}