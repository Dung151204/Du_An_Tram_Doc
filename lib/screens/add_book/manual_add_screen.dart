import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import 'book_preview_screen.dart';

// 1. Chuyển sang StatefulWidget để quản lý việc nhập liệu
class ManualAddScreen extends StatefulWidget {
  const ManualAddScreen({super.key});

  @override
  State<ManualAddScreen> createState() => _ManualAddScreenState();
}

class _ManualAddScreenState extends State<ManualAddScreen> {
  // 2. KHAI BÁO 2 BIẾN ĐANG BỊ THIẾU
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Nhập thủ công",
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh bìa (Giữ nguyên code của bạn)
            Center(
              child: Container(
                width: 140,
                height: 190,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(LucideIcons.camera, color: AppColors.textGrey, size: 32),
                    SizedBox(height: 8),
                    Text("Ảnh bìa", style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 2. Các ô nhập liệu (Đã truyền controller vào)
            _buildLabel("Tên sách"),
            _buildInput("Nhập tên sách...", controller: _titleController), // <-- Truyền biến vào đây
            const SizedBox(height: 20),

            _buildLabel("Tác giả"),
            _buildInput("Tên tác giả...", controller: _authorController), // <-- Truyền biến vào đây
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildLabel("Số trang"), _buildInput("0")],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Thể loại"),
                      _buildInput("Chọn", isDropdown: true)
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // 3. Nút Lưu lại
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),

                // SỰ KIỆN KHI BẤM NÚT (Giờ đã hết lỗi đỏ)
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BookPreviewScreen(
                            bookTitle: _titleController.text, // Đã lấy được chữ
                            author: _authorController.text,   // Đã lấy được chữ
                          )
                      )
                  );
                },

                child: const Text(
                    "Lưu lại",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  // Cập nhật hàm này để nhận biến controller
  Widget _buildInput(String hint, {bool isDropdown = false, TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller, // <-- Gắn biến vào đây để nhận chữ
        readOnly: isDropdown,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: isDropdown ? const Icon(LucideIcons.chevronDown, size: 20, color: AppColors.textGrey) : null,
        ),
      ),
    );
  }
}