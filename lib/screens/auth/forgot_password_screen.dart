import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import 'forgot_password_success.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(LucideIcons.chevronLeft, color: AppColors.textDark, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Key vàng
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle), // Vàng nhạt
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

            // Input Email
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withOpacity(0.5), // Xám xanh rất nhạt
                borderRadius: BorderRadius.circular(16),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Nhập email của bạn",
                  hintStyle: TextStyle(color: AppColors.textGrey),
                  prefixIcon: Icon(LucideIcons.mail, color: AppColors.textGrey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Button Gửi
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Chuyển sang màn hình thông báo thành công
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordSuccessScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Gửi liên kết", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}