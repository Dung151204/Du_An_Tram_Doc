import 'package:cloud_firestore/cloud_firestore.dart'; // Thư viện Firestore
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';

// [QUAN TRỌNG] Import màn hình tìm kiếm vừa tạo (Sửa lại đường dẫn nếu cần)
import '../community/search_user_screen.dart';
import '../auth/login_screen.dart';
import '../../services/database_service.dart'; // Import service để dùng toggleFollow
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _redForLogout = Color(0xFFEF4444);

  // --- HÀM XỬ LÝ ĐĂNG XUẤT ---
  void _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
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
    // Lấy ID người dùng hiện tại
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text("Vui lòng đăng nhập lại"));

    return Scaffold(
      backgroundColor: AppColors.background,
      // Truyền context vào AppBar để điều hướng
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Hiển thị Profile thật từ Firebase
              _buildRealProfileInfo(context, user.uid),
              const SizedBox(height: 32),
              // Hiển thị danh sách bạn bè thật
              _buildRealFriendsList(user.uid),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget: AppBar (Đã thêm nút Tìm kiếm) ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark),
        onPressed: () {
          // Xử lý nút back nếu cần
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
      title: const Text(
        'Hồ sơ',
        style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark,
        ),
      ),
      actions: [
        // [MỚI] Nút Tìm kiếm bạn bè
        IconButton(
          icon: const Icon(LucideIcons.userPlus, color: Colors.blueAccent),
          tooltip: "Tìm bạn bè",
          onPressed: () {
            // Chuyển sang màn hình tìm kiếm
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchUserScreen()),
            );
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  // --- Widget: Hiển thị thông tin Profile thật ---
  Widget _buildRealProfileInfo(BuildContext context, String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var userData = snapshot.data!.data() as Map<String, dynamic>?;

        // Dữ liệu mặc định nếu chưa có
        String name = userData?['fullName'] ?? 'Người dùng';
        String email = userData?['email'] ?? '';
        String initials = name.isNotEmpty ? name[0].toUpperCase() : "U";

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // Sửa lại withOpacity cho tương thích bản cũ
                blurRadius: 8, offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.textDark,
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(email, style: TextStyle(fontSize: 14, color: AppColors.textGrey)),
                ],
              ),
              const SizedBox(height: 32),

              // Thống kê (Tạm thời để cứng hoặc query đếm sau)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('12', 'SÁCH'),
                  _buildStatItem('5', 'CHUỖI'),
                  _buildStatItem('48', 'GHI CHÚ'),
                ],
              ),
              const SizedBox(height: 32),

              OutlinedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(LucideIcons.logOut, size: 18),
                label: const Text('Đăng xuất'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _redForLogout,
                  side: const BorderSide(color: _redForLogout, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Widget: Danh sách Bạn bè (Following) Thật ---
  Widget _buildRealFriendsList(String currentUserId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ĐANG THEO DÕI',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textGrey),
            ),
            // Gợi ý bấm nút tìm kiếm
            GestureDetector(
              onTap: (){}, // Có thể mở SearchUserScreen tại đây luôn
              child: const Text("Thêm bạn +", style: TextStyle(color: Colors.blue, fontSize: 12)),
            )
          ],
        ),
        const SizedBox(height: 16),

        // Stream lấy danh sách ID những người mình đang theo dõi
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('following')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(12)
                ),
                child: const Column(
                  children: [
                    Icon(LucideIcons.userX, color: Colors.grey, size: 40),
                    SizedBox(height: 8),
                    Text("Bạn chưa theo dõi ai cả.", style: TextStyle(color: Colors.grey)),
                    Text("Bấm icon góc trên để tìm bạn bè!", style: TextStyle(color: Colors.blue, fontSize: 12)),
                  ],
                ),
              );
            }

            final followingDocs = snapshot.data!.docs;

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: followingDocs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                // Lấy ID của người mình theo dõi
                String targetUserId = followingDocs[index].id;

                // Fetch thông tin chi tiết của người đó (Tên, Email...)
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(targetUserId).get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) return const SizedBox(); // Đang tải từng item

                    var userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                    String friendName = userData?['fullName'] ?? 'Không tên';
                    String initials = friendName.isNotEmpty ? friendName[0].toUpperCase() : "?";

                    return _buildFriendItem(
                      initials: initials,
                      name: friendName,
                      // Có thể cập nhật status đọc sách sau này
                      status: userData?['email'] ?? 'Thành viên Trạm Đọc',
                      avatarColor: (index % 2 == 0) ? AppColors.amber : AppColors.primary,
                      targetUserId: targetUserId, // Truyền ID để nút Follow hoạt động
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // --- Widget: Item Bạn bè (Đã gắn chức năng Hủy theo dõi) ---
  Widget _buildFriendItem({
    required String initials,
    required String name,
    required String status,
    required Color avatarColor,
    required String targetUserId, // [QUAN TRỌNG] ID để xử lý
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 4),
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
              style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(status, style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),

          // Nút Đang theo dõi (Bấm vào để hủy)
          OutlinedButton(
            onPressed: () {
              // Gọi hàm từ DatabaseService để Hủy theo dõi
              DatabaseService().toggleFollow(targetUserId);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.green, width: 1),
              backgroundColor: Colors.green.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text(
              'Đang theo dõi',
              style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

}