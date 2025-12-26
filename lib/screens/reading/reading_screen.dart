import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ReadingScreen extends StatelessWidget {
  final String bookTitle;
  final String content;

  const ReadingScreen({
    super.key,
    required this.bookTitle,
    this.content = "",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: Text(bookTitle, style: const TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: const Color(0xFFFFFBF0),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          content.isNotEmpty ? content : "Chưa có nội dung. Hãy cập nhật lại nhé!",
          style: const TextStyle(fontSize: 18, height: 1.8, color: AppColors.textDark, fontFamily: 'Serif'),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}