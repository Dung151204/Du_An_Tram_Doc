// File: lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Thư viện này sẽ hết đỏ sau khi chạy lệnh ở Bước 1
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../main_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // KHAI BÁO: Tên biến là _passController (viết tắt)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    // SỬA LỖI: Dùng đúng tên biến _passController
    if (_emailController.text.trim().isEmpty || _passController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ Email và Mật khẩu!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(), // Đã sửa lại đúng tên biến ở đây
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng nhập thất bại. Vui lòng thử lại.';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = 'Tài khoản hoặc mật khẩu không đúng.';
      } else if (e.code == 'wrong-password') {
        message = 'Sai mật khẩu.';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF3F4E66),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(LucideIcons.bookOpen, size: 40, color: AppColors.amber),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Trạm Đọc",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Đọc sách, Ghi chú, Kiến tạo",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // FORM
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Đăng nhập", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 24),

                  CustomTextField(
                    label: "Email",
                    icon: LucideIcons.mail,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: "Mật khẩu",
                    icon: LucideIcons.lock,
                    isPassword: true,
                    controller: _passController, // Đã gắn đúng controller
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                      },
                      child: const Text("Quên mật khẩu?", style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.amber))
                      : CustomButton(
                    text: "Đăng nhập",
                    icon: LucideIcons.arrowRight,
                    onPressed: _handleLogin,
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Bạn chưa có tài khoản? ", style: TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                        },
                        child: const Text("Đăng ký", style: TextStyle(color: AppColors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}