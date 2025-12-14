import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Đổi import từ main_wrapper sang login_screen
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trạm Đọc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      // Đổi home thành LoginScreen
      home: const LoginScreen(),
    );
  }
}