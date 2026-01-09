// File: lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // [MỚI] Thêm thư viện Auth
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import 'forgot_password_success.dart';

// [MỚI] Chuyển thành StatefulWidget để xử lý logic
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  // Hàm gửi email reset mật khẩu
  Future<void> _sendResetEmail() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập email"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Gửi yêu cầu lên Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Nếu thành công -> Chuyển sang màn hình thông báo
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPasswordSuccessScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Có lỗi xảy ra";
      if (e.code == 'user-not-found') message = "Email này chưa được đăng ký!";
      if (e.code == 'invalid-email') message = "Email không đúng định dạng!";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

            // Input Email
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0).withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _emailController, // [MỚI] Gắn controller vào đây
                decoration: const InputDecoration(
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
                onPressed: _isLoading ? null : _sendResetEmail, // [MỚI] Gọi hàm gửi email
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Gửi liên kết", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}