import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';

class ForgotPasswordSuccessScreen extends StatelessWidget {
  const ForgotPasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
              child: const Icon(LucideIcons.key, color: AppColors.amber, size: 24),
            ),
            const SizedBox(height: 24),
            const Text("Quên mật khẩu?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            const Text(
              "Đừng lo lắng! Hãy nhập email đã đăng ký, chúng tôi sẽ gửi liên kết đặt lại mật khẩu cho bạn.",
              style: TextStyle(color: AppColors.textGrey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Khối thông báo thành công màu xanh lá
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7).withOpacity(0.5), // Xanh lá rất nhạt
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF86EFAC).withOpacity(0.5)),
              ),
              child: Column(
                children: const [
                  Icon(LucideIcons.checkCircle, color: Color(0xFF22C55E), size: 48),
                  SizedBox(height: 16),
                  Text("Đã gửi liên kết!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                  SizedBox(height: 8),
                  Text(
                    "Vui lòng kiểm tra hộp thư đến của bạn. Đang quay lại màn hình đăng nhập...",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Nút quay lại đăng nhập ở dưới cùng
            Center(
              child: TextButton(
                onPressed: () {
                  // Quay về màn Login (Xóa hết các màn hình trước đó)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("Quay lại Đăng nhập", style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}