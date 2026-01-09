import 'package:cloud_firestore/cloud_firestore.dart'; // Thư viện Firestore
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../community/search_user_screen.dart';
import '../auth/login_screen.dart';
import '../../services/database_service.dart';
import '../../models/book_model.dart';
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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text("Vui lòng đăng nhập lại"));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Hiển thị Profile thật
              _buildRealProfileInfo(context, user.uid),
              const SizedBox(height: 32),
              // [QUAN TRỌNG] Đã truyền context vào đây để sửa lỗi
              _buildRealFriendsList(context, user.uid),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false, // [QUAN TRỌNG] Đảm bảo không hiện nút back tự động
      // Đã xóa thuộc tính leading (nút quay lại thủ công)
      centerTitle: true,
      title: const Text(
        'Hồ sơ',
        style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.userPlus, color: Colors.blueAccent),
          tooltip: "Tìm bạn bè",
          onPressed: () {
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

  Widget _buildRealProfileInfo(BuildContext context, String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());

        var userData = userSnapshot.data!.data() as Map<String, dynamic>?;

        String name = userData?['fullName'] ?? 'Người dùng';
        String email = userData?['email'] ?? '';
        String initials = name.isNotEmpty ? name[0].toUpperCase() : "U";
        int currentStreak = userData?['currentStreak'] ?? 0;

        return StreamBuilder<List<BookModel>>(
          stream: DatabaseService().getBooks(),
          builder: (context, bookSnapshot) {
            final books = bookSnapshot.data ?? [];

            int totalBooks = books.length;
            int totalNotes = books.fold(0, (sum, book) => sum + book.keyTakeaways.length);

            return Container(
              padding: const EdgeInsets.all(24),
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
                      if (currentStreak > 0) ...[
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.flame, color: Colors.orange, size: 16),
                      ]
                    ],
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('$totalBooks', 'SÁCH'),
                      _buildStatItem('$currentStreak', 'CHUỖI'),
                      _buildStatItem('$totalNotes', 'GHI CHÚ'),
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
      },
    );
  }

  // [ĐÃ SỬA] Thêm tham số BuildContext context vào đây
  Widget _buildRealFriendsList(BuildContext context, String currentUserId) {
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
            GestureDetector(
              onTap: (){
                // Giờ đã có context để dùng
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchUserScreen()),
                );
              },
              child: const Text("Thêm bạn +", style: TextStyle(color: Colors.blue, fontSize: 12)),
            )
          ],
        ),
        const SizedBox(height: 16),

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
                String targetUserId = followingDocs[index].id;

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(targetUserId).get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) return const SizedBox();

                    var userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                    String friendName = userData?['fullName'] ?? 'Không tên';
                    String initials = friendName.isNotEmpty ? friendName[0].toUpperCase() : "?";

                    return _buildFriendItem(
                      initials: initials,
                      name: friendName,
                      status: userData?['email'] ?? 'Thành viên Trạm Đọc',
                      avatarColor: (index % 2 == 0) ? AppColors.amber : AppColors.primary,
                      targetUserId: targetUserId,
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

  Widget _buildFriendItem({
    required String initials,
    required String name,
    required String status,
    required Color avatarColor,
    required String targetUserId,
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

          OutlinedButton(
            onPressed: () {
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
              'Hủy theo dõi',
              style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}