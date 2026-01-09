import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/database_service.dart';
import '../../models/book_model.dart';
import '../community/search_user_screen.dart'; // Import màn hình tìm bạn
import '../../../core/constants/app_colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Biến lưu danh sách ID bạn bè
  List<String> _followingIds = [];
  bool _isLoadingIds = true;

  @override
  void initState() {
    super.initState();
    _loadFollowingIds();
  }

  // Tải danh sách người mình đang theo dõi
  Future<void> _loadFollowingIds() async {
    final ids = await DatabaseService().getFollowingUserIds();
    if (mounted) {
      setState(() {
        _followingIds = ids;
        _isLoadingIds = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Màu nền nhẹ nhàng
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Trạm Tin",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.userPlus, color: Colors.black),
            onPressed: () {
              // Chuyển sang màn hình tìm bạn
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchUserScreen()))
                  .then((_) => _loadFollowingIds()); // Load lại danh sách khi quay về
            },
          )
        ],
      ),
      body: _isLoadingIds
          ? const Center(child: CircularProgressIndicator())
          : _followingIds.isEmpty
          ? _buildEmptyState() // Chưa theo dõi ai
          : StreamBuilder<List<BookModel>>(
        stream: DatabaseService().getFriendsBooks(_followingIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBooks = snapshot.data ?? [];

          // LỌC: Chỉ hiện những cuốn có Hoạt động (Có Rating hoặc Có Ghi chú)
          final activeBooks = allBooks.where((book) {
            bool hasRating = book.rating > 0;
            bool hasNotes = book.keyTakeaways.isNotEmpty;
            return hasRating || hasNotes;
          }).toList();

          if (activeBooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.coffee, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("Bạn bè của bạn đang 'im hơi lặng tiếng'...", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text("Chưa có hoạt động mới nào.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeBooks.length,
            itemBuilder: (context, index) {
              return _buildActivityCard(activeBooks[index]);
            },
          );
        },
      ),
    );
  }

  // Card hiển thị hoạt động của bạn bè
  Widget _buildActivityCard(BookModel book) {
    // Xác định loại hoạt động để hiển thị tiêu đề
    bool isReview = book.rating > 0;
    bool isNote = book.keyTakeaways.isNotEmpty;

    String actionText = "đang đọc";
    if (isReview && isNote) actionText = "vừa đánh giá & ghi chú";
    else if (isReview) actionText = "đã đánh giá sách";
    else if (isNote) actionText = "vừa thêm ghi chú mới";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Thông tin người bạn (Avatar + Tên lấy từ Users collection)
          _buildUserHeader(book.userId!, actionText),

          const Divider(height: 1),

          // 2. Body: Thông tin sách
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh bìa sách
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: book.imageUrl.isNotEmpty
                      ? (book.imageUrl.startsWith('http')
                      ? Image.network(book.imageUrl, width: 60, height: 90, fit: BoxFit.cover)
                      : Image.file(File(book.imageUrl), width: 60, height: 90, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey[200]))
                  )
                      : Container(width: 60, height: 90, color: Colors.grey[200], child: const Icon(Icons.book)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(book.author, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 8),

                      // Hiển thị Rating nếu có
                      if (isReview)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              Text(" ${book.rating} sao", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800, fontSize: 12)),
                            ],
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // 3. Footer: Hiển thị Ghi chú (Nếu có)
          if (isNote)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [
                    Icon(LucideIcons.stickyNote, size: 16, color: Colors.blueGrey),
                    SizedBox(width: 8),
                    Text("Ghi chú được chia sẻ:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 13)),
                  ]),
                  const SizedBox(height: 8),
                  // Chỉ hiện tối đa 2 ghi chú đầu tiên để gọn
                  ...book.keyTakeaways.take(2).map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text("• $note", style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87)),
                  )),
                  if (book.keyTakeaways.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text("+ còn ${book.keyTakeaways.length - 2} ý khác...", style: const TextStyle(color: Colors.blue, fontSize: 12, fontStyle: FontStyle.italic)),
                    )
                ],
              ),
            )
        ],
      ),
    );
  }

  // Widget con: Tải tên người dùng từ userId
  Widget _buildUserHeader(String userId, String actionText) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        String name = "Người dùng";
        if (snapshot.hasData && snapshot.data!.exists) {
          name = (snapshot.data!.data() as Map<String, dynamic>)['fullName'] ?? "Người dùng";
        }

        String initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue.shade100,
                child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(actionText, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.users, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 24),
          const Text("Kết nối cộng đồng", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Theo dõi bạn bè để xem họ đang đọc gì, đánh giá sách nào và chia sẻ những ghi chú hay!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchUserScreen()))
                  .then((_) => _loadFollowingIds());
            },
            icon: const Icon(Icons.person_add),
            label: const Text("Tìm bạn bè ngay"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          )
        ],
      ),
    );
  }
}