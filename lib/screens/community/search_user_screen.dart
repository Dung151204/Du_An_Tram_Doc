import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Nhập tên người cần tìm...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _searchQuery.isEmpty
          ? const Center(child: Text("Nhập tên để tìm kiếm bạn bè"))
          : StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().searchUsers(_searchQuery),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs;

          // Lọc bỏ bản thân mình ra khỏi kết quả tìm kiếm
          final filteredUsers = users.where((doc) => doc.id != currentUserId).toList();

          if (filteredUsers.isEmpty) {
            return const Center(child: Text("Không tìm thấy ai"));
          }

          return ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              var user = filteredUsers[index];
              // Lưu ý: Đảm bảo field tên trong Firebase là 'fullName' hoặc 'displayName'
              // Nếu bạn dùng field khác thì sửa lại dòng dưới nhé
              String name = (user.data() as Map<String, dynamic>)['fullName'] ?? "Không tên";
              String email = (user.data() as Map<String, dynamic>)['email'] ?? "";
              String uid = user.id;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?"),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(email),
                trailing: _FollowButton(targetUserId: uid),
              );
            },
          );
        },
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
            backgroundColor: isFollowing ? Colors.grey[300] : Colors.blue,
            foregroundColor: isFollowing ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(isFollowing ? "Đang theo dõi" : "Theo dõi"),
        );
      },
    );
  }
}