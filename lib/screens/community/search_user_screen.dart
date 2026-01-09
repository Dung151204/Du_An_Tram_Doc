import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Đảm bảo import đúng gói icon
import '../../services/database_service.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
              // [QUAN TRỌNG] Gợi ý người dùng tìm được cả 2 cách
              hintText: "Nhập Email (chính xác) hoặc Tên...",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
              contentPadding: EdgeInsets.only(top: 8), // Căn giữa text
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildGuide() // Hướng dẫn ban đầu
          : StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().searchUsers(_searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Xử lý trường hợp không có dữ liệu hoặc danh sách rỗng
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.frown,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          "Không tìm thấy '$_searchQuery'",
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        // [GỢI Ý QUAN TRỌNG]
                        const Text(
                          "Mẹo: Hãy thử nhập chính xác Email của bạn bè.",
                          style:
                              TextStyle(color: Colors.blueAccent, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                final users = snapshot.data!.docs;

                // Lọc bỏ bản thân mình ra khỏi kết quả tìm kiếm
                final filteredUsers =
                    users.where((doc) => doc.id != currentUserId).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                      child: Text("Không tìm thấy ai khác ngoài bạn"));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredUsers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    var user = filteredUsers[index];
                    // Ép kiểu dữ liệu an toàn
                    var data = user.data() as Map<String, dynamic>;

                    String name = data['fullName'] ?? "Không tên";
                    String email = data['email'] ?? "";
                    String uid = user.id;
                    String initial =
                        name.isNotEmpty ? name[0].toUpperCase() : "?";

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent.withOpacity(0.1),
                          child: Text(initial,
                              style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold)),
                        ),
                        title: Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(email),
                        trailing: _FollowButton(targetUserId: uid),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // Widget hiển thị hướng dẫn khi chưa nhập gì
  Widget _buildGuide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.users, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 24),
            const Text(
              "Tìm bạn bè",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Nhập tên để khám phá hoặc nhập Email (ví dụ: abc@gmail.com) để kết bạn chính xác nhất.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Nút Theo dõi riêng biệt để xử lý trạng thái realtime
class _FollowButton extends StatelessWidget {
  final String targetUserId;
  const _FollowButton({required this.targetUserId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: DatabaseService().isFollowing(targetUserId),
      builder: (context, snapshot) {
        bool isFollowing = snapshot.data ?? false;

        return ElevatedButton(
          onPressed: () {
            DatabaseService().toggleFollow(targetUserId);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey[200] : Colors.blueAccent,
            foregroundColor: isFollowing ? Colors.black87 : Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(isFollowing ? "Đã theo dõi" : "Theo dõi",
              style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}
