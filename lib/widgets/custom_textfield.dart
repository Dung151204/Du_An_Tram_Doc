import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart'; // Nhớ trỏ đúng đường dẫn màu

class CustomTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller; // Thêm cái này để lấy dữ liệu nhập

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _isObscure : false,
        decoration: InputDecoration(
          hintText: widget.label,
          hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
          prefixIcon: Icon(widget.icon, color: AppColors.textGrey, size: 20),
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _isObscure ? Icons.visibility : Icons.visibility_off, // Dùng icon có sẵn hoặc Lucide
              color: AppColors.textGrey,
              size: 20,
            ),
            onPressed: () => setState(() => _isObscure = !_isObscure),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}