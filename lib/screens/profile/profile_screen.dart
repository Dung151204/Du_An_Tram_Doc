import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Thư viện Firebase

// [ĐÃ SỬA] Đường dẫn đúng để tìm file Login (Thoát ra khỏi thư mục profile -> vào thư mục auth)
import '../auth/login_screen.dart';

import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _redForLogout = Color(0xFFEF4444);

  // --- HÀM XỬ LÝ ĐĂNG XUẤT ---
  void _handleLogout(BuildContext context) async {
    try {
      // 1. Đăng xuất khỏi Firebase
      await FirebaseAuth.instance.signOut();

      // 2. Kiểm tra context còn tồn tại không trước khi chuyển trang
      if (context.mounted) {
        // 3. Chuyển về màn hình Login và XÓA HẾT lịch sử các màn hình cũ
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi đăng xuất: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildProfileCard(context), // Truyền context vào để dùng cho nút Logout
              const SizedBox(height: 32),
              _buildFriendsSection(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget: AppBar ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark),
        onPressed: () {},
      ),
      centerTitle: true,
      title: const Text(
        'Hồ sơ',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  // --- Widget: Card chứa thông tin Hồ sơ ---
  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // [ĐÃ SỬA] Dùng cú pháp mới để hết lỗi vàng (Deprecated)
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Avatar lớn
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.textDark,
            child: Text(
              'MH',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Tên người dùng
          const Text(
            'Minh Hải',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),

          // 3. Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mọt sách chính hiệu',
                style: TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),
              const SizedBox(width: 4),
              const Text('📚', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 32),

          // 4. Số liệu thống kê
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('12', 'SÁCH'),
              _buildStatItem('5', 'CHUỖI'),
              _buildStatItem('48', 'GHI CHÚ'),
            ],
          ),
          const SizedBox(height: 32),

          // 5. Nút Đăng xuất (Đã gắn hàm xử lý)
          OutlinedButton.icon(
            onPressed: () => _handleLogout(context), // Gọi hàm đăng xuất
            icon: const Icon(LucideIcons.logOut, size: 18),
            label: const Text('Đăng xuất'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _redForLogout,
              side: const BorderSide(color: _redForLogout, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Mục thống kê con ---
  Widget _buildStatItem(String count, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // --- Widget: Phần Bạn bè ---
  Widget _buildFriendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BẠN BÈ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 16),
        _buildFriendItem(
          initials: 'DN',
          name: 'Dũng Ngô',
          status: 'Đang đọc Đắc Nhân Tâm',
          avatarColor: AppColors.amber,
        ),
        const SizedBox(height: 16),
        _buildFriendItem(
          initials: 'AT',
          name: 'Anh Thi',
          status: 'Đang đọc Đi Tìm Lẽ Sống',
          avatarColor: AppColors.primary,
        ),
      ],
    );
  }

  // --- Widget: Item Bạn bè ---
  Widget _buildFriendItem({
    required String initials,
    required String name,
    required String status,
    required Color avatarColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // [ĐÃ SỬA] Dùng cú pháp mới
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.textGrey, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: Text(
              'Theo dõi',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}