import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart'; // Import model
import '../../models/review_model.dart';
import '../../services/database_service.dart';

class RatingScreen extends StatefulWidget {
  final dynamic book; // Nhận cả BookModel hoặc Map

  const RatingScreen({super.key, required this.book});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _currentRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  void _setRating(int rating) {
    setState(() => _currentRating = rating.toDouble());
  }

  Future<void> _submitReview() async {
    if (_currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn số sao!")));
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hãy viết cảm nhận của bạn!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Xử lý dữ liệu Book để lấy đúng ID và Rating cũ
      BookModel bookData;
      if (widget.book is BookModel) {
        bookData = widget.book;
      } else {
        // Nếu là Map (từ màn hình tìm kiếm), chuyển đổi sang BookModel tạm
        bookData = BookModel(
          id: widget.book['id'],
          title: widget.book['title'] ?? '',
          author: widget.book['author'] ?? '',
          description: '', content: '', imageUrl: '',
          totalPages: 0, createdAt: DateTime.now(),
          // Quan trọng: Lấy đúng rating và reviewsCount để tính toán
          rating: (widget.book['rating'] is int)
              ? (widget.book['rating'] as int).toDouble()
              : (widget.book['rating'] ?? 0.0),
          reviewsCount: widget.book['reviewsCount'] ?? 0,
        );
      }

      final newReview = ReviewModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookId: bookData.id ?? "unknown",
        userId: user?.uid ?? "guest",
        userName: user?.displayName ?? "Người dùng ẩn danh",
        rating: _currentRating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Gọi hàm mới có truyền bookData để tính điểm
      await DatabaseService().addReview(newReview, bookData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Đã gửi đánh giá!"), backgroundColor: Colors.green));
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
    String title = (widget.book is Map) ? widget.book['title'] : widget.book.title;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("Viết đánh giá", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text("Bạn thấy cuốn sách này thế nào?", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 40,
                  icon: Icon(index < _currentRating ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.amber),
                  onPressed: () => _setRating(index + 1),
                );
              }),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Nhập nội dung đánh giá...",
                fillColor: const Color(0xFFF8F9FA), filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text("Gửi đánh giá", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _isLoading ? null : _submitReview,
              ),
            ),
          ],
        ),
      ),
    );
  }
}