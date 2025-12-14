import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  bool _isFlashcardChecked = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text("Ghi chú & AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              // HIỆN DIALOG THÀNH CÔNG (MÀN 3)
              _showSuccessDialog(context);
            },
            child: const Text("Lưu", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Ô Nhập liệu (Trông giống tờ giấy)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const TextField(
                  maxLines: null, // Cho phép xuống dòng thoải mái
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Viết suy nghĩ của bạn, hoặc dùng OCR quét trang sách...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Nút Quét văn bản (Màu xanh dương nhạt)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0E7FF), // Xanh dương nhạt
                  foregroundColor: const Color(0xFF4338CA), // Chữ xanh đậm
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(LucideIcons.camera, size: 20),
                    SizedBox(width: 8),
                    Text("Quét văn bản (OCR)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Checkbox Tạo Flashcard
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Custom Checkbox màu cam
                  GestureDetector(
                    onTap: () => setState(() => _isFlashcardChecked = !_isFlashcardChecked),
                    child: Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: _isFlashcardChecked ? Colors.orange : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _isFlashcardChecked ? Colors.orange : Colors.grey.shade300),
                      ),
                      child: _isFlashcardChecked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Tạo Flashcard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 2),
                      Text("Hệ thống sẽ nhắc bạn ôn tập lại ý này", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- HÀM HIỆN DIALOG THÀNH CÔNG (MÀN 3) ---
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc bấm nút mới tắt
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Dialog co lại vừa nội dung
              children: [
                // Icon V xanh
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.check, color: Color(0xFF16A34A), size: 32),
                ),
                const SizedBox(height: 20),
                const Text("Đã lưu Flashcard!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  "Hệ thống đã tạo thẻ ôn tập cho\nbạn dựa trên ghi chú vừa rồi",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Nút Ôn tập ngay (Màu đen)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Đóng dialog
                      // Xử lý chuyển sang màn ôn tập sau
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Ôn tập ngay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(LucideIcons.arrowRight, size: 16, color: Colors.white)
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Nút Tiếp tục đọc (Màu xám)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Đóng dialog
                      Navigator.pop(context); // Đóng màn hình ghi chú, quay lại chi tiết sách
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text("Tiếp tục đọc", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}