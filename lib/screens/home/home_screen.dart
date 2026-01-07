import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../services/database_service.dart';
import '../../models/book_model.dart';
import 'library_screen.dart';
import 'note_book_selection_screen.dart';
import 'physical_book_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // Lấy tên người dùng hoặc mặc định
    String displayName = user?.displayName ?? "Bạn";

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Màu nền xám xanh hiện đại
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER CHÀO MỪNG
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  // Avatar giả lập
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                      image: const DecorationImage(image: NetworkImage("https://i.pravatar.cc/150?img=11")), // Ảnh mẫu
                    ),
                  )
                ],
              ),

              const SizedBox(height: 32),

              const Text("Quản lý", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 16),

              // 2. MODULE 1: THƯ VIỆN THÔNG MINH
              // Dùng StreamBuilder để đếm tổng số sách
              StreamBuilder<List<BookModel>>(
                stream: DatabaseService().getBooks(),
                builder: (context, snapshot) {
                  int totalBooks = snapshot.data?.length ?? 0;
                  return _buildModernCard(
                    context,
                    title: "Thư viện thông minh",
                    subtitle: "Quản lý 3 kệ sách & Tiến độ đọc",
                    stat: "$totalBooks cuốn",
                    icon: LucideIcons.library,
                    gradientColors: [Colors.blue.shade400, Colors.blue.shade700],
                    shadowColor: Colors.blue.withOpacity(0.3),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryScreen())),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 3. MODULE 2: QUẢN LÝ SÁCH GIẤY
              // Dùng StreamBuilder để đếm sách đang cho mượn
              StreamBuilder<List<BookModel>>(
                stream: DatabaseService().getBooks(),
                builder: (context, snapshot) {
                  final books = snapshot.data ?? [];
                  int lentCount = books.where((b) => b.lentTo.isNotEmpty).length;

                  return _buildModernCard(
                    context,
                    title: "Quản lý Sách giấy",
                    subtitle: "Vị trí lưu trữ & Theo dõi mượn",
                    stat: lentCount > 0 ? "Đang cho mượn: $lentCount" : "Tất cả sách đang ở nhà",
                    icon: LucideIcons.mapPin,
                    gradientColors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                    shadowColor: Colors.orange.withOpacity(0.3),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PhysicalBookScreen())),
                  );
                },
              ),

              const SizedBox(height: 30),
              // MODULE 3: GHI CHÚ CHỦ ĐỘNG (Mới)
              _buildModuleCard(
                context,
                title: "Ghi chú Chủ động",
                subtitle: "Note theo trang & Scan text (OCR).\nTổng hợp 3-5 ý tưởng cốt lõi.",
                icon: LucideIcons.stickyNote,
                color: Colors.purple.shade600,
                onTap: () {
                  // Mở màn hình chọn sách trước khi vào ghi chú
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteBookSelectionScreen()));
                },
              ),

              // 4. MỘT CHÚT TRANG TRÍ (Tip of the day)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B), // Màu tối
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.sparkles, color: Colors.amber, size: 30),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Mẹo nhỏ", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          SizedBox(height: 4),
                          Text("Đọc 20 trang mỗi ngày giúp bạn hoàn thành 12 cuốn sách/năm!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget thẻ Card hiện đại
  Widget _buildModernCard(BuildContext context, {
    required String title,
    required String subtitle,
    required String stat,
    required IconData icon,
    required List<Color> gradientColors,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140, // Chiều cao cố định cho đẹp
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCBD5E1).withOpacity(0.3), // Bóng màu xám xanh
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background trang trí mờ nhạt
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: gradientColors.last.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Icon Box với Gradient
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 20),

                    // Nội dung chữ
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          const SizedBox(height: 4),
                          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 12),
                          // Badge thống kê
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: gradientColors.first.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              stat,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: gradientColors.last),
                            ),
                          )
                        ],
                      ),
                    ),

                    Icon(Icons.chevron_right, color: Colors.grey.shade300),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng ☀️';
    if (hour < 18) return 'Chào buổi chiều 🌤️';
    return 'Chào buổi tối 🌙';
  }
  // Dán đoạn này vào cuối class HomeScreen, trước dấu } đóng
  Widget _buildModuleCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 20), // Cách dưới 1 chút cho đẹp
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.5)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}