import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import thêm cái này
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'main_wrapper.dart'; // Import màn hình chính

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      // --- LOGIC TỰ ĐỘNG ĐĂNG NHẬP ---
      // Kiểm tra luồng dữ liệu người dùng (Stream)
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Nếu có dữ liệu user -> Vào thẳng MainWrapper
          if (snapshot.hasData) {
            return const MainWrapper();
          }
          // 2. Nếu không có (hoặc đã đăng xuất) -> Về trang Login
          return const LoginScreen();
        },
      ),
    );
  }
}