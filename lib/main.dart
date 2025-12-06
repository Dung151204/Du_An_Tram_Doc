import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trạm Đọc',
      debugShowCheckedModeBanner: false, // Tắt chữ DEBUG
      theme: ThemeData(
        // Cài đặt font chữ Google Inter cho toàn bộ App
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      home: const MainWrapper(), // Chạy vào khung sườn chính
    );
  }
}