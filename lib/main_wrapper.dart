import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'core/constants/app_colors.dart';
import 'screens/home/home_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  // Danh sách các màn hình (Placeholder)
  final List<Widget> _screens = [
    const HomeScreen(),
    const Scaffold(body: Center(child: Text("Màn hình Ôn tập"))),
    const Scaffold(body: Center(child: Text("Màn hình Cộng đồng"))),
    const Scaffold(body: Center(child: Text("Màn hình Hồ sơ"))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng Stack để thanh menu nổi lên trên nội dung
      body: Stack(
        children: [
          // 1. Nội dung màn hình (Nằm dưới)
          _screens[_selectedIndex],

          // 2. Thanh Menu nổi (Floating Bottom Bar)
          Positioned(
            bottom: 24, // Cách đáy 24px
            left: 24,
            right: 24,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(LucideIcons.bookOpen, "Thư viện", 0),
                  _buildNavItem(LucideIcons.repeat, "Ôn tập", 1),

                  // Nút (+) Lồi lên ở giữa
                  GestureDetector(
                    onTap: () {
                      print("Bấm nút Thêm");
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      margin: const EdgeInsets.only(bottom: 24), // Đẩy lên cao
                      decoration: BoxDecoration(
                        color: AppColors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.amber.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.plus, color: Colors.white),
                    ),
                  ),

                  _buildNavItem(LucideIcons.users, "Cộng đồng", 2),
                  _buildNavItem(LucideIcons.user, "Hồ sơ", 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget con để tạo từng icon trong menu
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        color: Colors.transparent, // Để dễ bấm
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textGrey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}