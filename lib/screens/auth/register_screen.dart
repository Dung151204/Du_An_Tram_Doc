// File: lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart'; // Dùng lại nút bấm chuẩn của dự án
import '../../widgets/custom_textfield.dart'; // Dùng lại ô nhập chuẩn
import '../../main_wrapper.dart'; // Màn hình chính

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Tạo các bộ điều khiển để lấy dữ liệu nhập vào
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController(); // Thêm ô nhập lại mật khẩu cho chắc

  bool _isLoading = false;

  // 2. Hàm xử lý Đăng Ký (Có Log để bắt lỗi)
  Future<void> _handleRegister() async {
    print("🟢 Nút Đăng ký đã được bấm!"); // Log 1

    // Kiểm tra nhập liệu
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passController.text.trim().isEmpty) {
      _showError("Vui lòng điền đầy đủ thông tin");
      return;
    }

    if (_passController.text != _confirmPassController.text) {
      _showError("Mật khẩu nhập lại không khớp");
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("🟡 Đang gửi yêu cầu tạo tài khoản lên Firebase..."); // Log 2

      // GỌI FIREBASE TẠO TÀI KHOẢN
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );

      print("🟢 Tạo tài khoản thành công! UID: ${userCredential.user?.uid}"); // Log 3

      // Cập nhật tên hiển thị
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // Chuyển sang màn hình chính (Xóa hết lịch sử quay lại)
      if (mounted) {
        print("🟢 Đang chuyển hướng sang MainWrapper...");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
              (route) => false,
        );
      }
    } catch (e) {
      // BẮT LỖI VÀ IN RA MÀN HÌNH
      print("🔴 LỖI FIREBASE: $e"); // Log Lỗi

      String message = "Đăng ký thất bại";
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') message = "Email này đã có người dùng!";
        if (e.code == 'invalid-email') message = "Email không hợp lệ!";
        if (e.code == 'weak-password') message = "Mật khẩu quá yếu (cần 6 ký tự trở lên)!";
      }
      _showError(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header (Giữ nguyên cho đẹp)
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF3F4E66),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(LucideIcons.bookOpen, size: 40, color: AppColors.amber),
                  ),
                  const SizedBox(height: 16),
                  const Text("Trạm Đọc", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text("Đọc sách, Ghi chú, Kiến tạo", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),

            // Form Đăng ký
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tạo tài khoản", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 24),

                  // Dùng CustomTextField (Widget chung) để code gọn hơn
                  CustomTextField(
                    label: "Tên hiển thị",
                    icon: LucideIcons.user,
                    controller: _nameController, // Gắn biến hứng dữ liệu
                  ),
                  const SizedBox(height: 16),

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
                    controller: _passController,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: "Nhập lại mật khẩu",
                    icon: LucideIcons.lock,
                    isPassword: true,
                    controller: _confirmPassController,
                  ),

                  const SizedBox(height: 32),

                  // Nút bấm có hiệu ứng loading
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : CustomButton(
                    text: "Đăng ký ngay",
                    icon: LucideIcons.arrowRight,
                    onPressed: _handleRegister, // Gọi hàm xử lý Firebase
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Đã có tài khoản? ", style: TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text("Đăng nhập", style: TextStyle(color: AppColors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
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