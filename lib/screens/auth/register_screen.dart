// File: lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // [MỚI] Thêm thư viện này
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../main_wrapper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleRegister() async {
    // 1. Kiểm tra nhập liệu
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
      // 2. TẠO TÀI KHOẢN AUTHENTICATION
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );

      // Cập nhật tên hiển thị ngay lập tức
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      String uid = userCredential.user!.uid;

      // 3. [QUAN TRỌNG] LƯU DỮ LIỆU NGƯỜI DÙNG VÀO FIRESTORE
      // Đây là bước giúp bạn có đầy đủ thông tin User trong Database
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(), // Lưu thời gian tạo
        'role': 'user',
        'lastReviewDate': null, // Trường này để phục vụ tính năng ôn tập sau này
      });

      // 4. Chuyển sang màn hình chính
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
              (route) => false,
        );
      }
    } catch (e) {
      String message = "Đăng ký thất bại";
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') message = "Email này đã được sử dụng!";
        if (e.code == 'invalid-email') message = "Email không hợp lệ!";
        if (e.code == 'weak-password') message = "Mật khẩu quá yếu (cần 6 ký tự)!";
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
            // Header
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

            // Form
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tạo tài khoản", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 24),

                  CustomTextField(label: "Tên hiển thị", icon: LucideIcons.user, controller: _nameController),
                  const SizedBox(height: 16),
                  CustomTextField(label: "Email", icon: LucideIcons.mail, controller: _emailController),
                  const SizedBox(height: 16),
                  CustomTextField(label: "Mật khẩu", icon: LucideIcons.lock, isPassword: true, controller: _passController),
                  const SizedBox(height: 16),
                  CustomTextField(label: "Nhập lại mật khẩu", icon: LucideIcons.lock, isPassword: true, controller: _confirmPassController),

                  const SizedBox(height: 32),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : CustomButton(
                    text: "Đăng ký ngay",
                    icon: LucideIcons.arrowRight,
                    onPressed: _handleRegister,
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