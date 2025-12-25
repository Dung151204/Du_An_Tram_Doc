import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER: Trạm Tin
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Trạm Tin",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Icon(
                    LucideIcons.users,
                    size: 22,
                    color: AppColors.textDark,
                  ), // Icon người dùng
                ],
              ),
              const SizedBox(height: 20),

              // CARD SÁCH HAY TUẦN NÀY (Có tương tác nút Tham gia ngay)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // Màu tím từ ảnh
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.menu_book, color: AppColors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "Sách hay tuần này",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "3 người bạn của bạn đang đọc “Sapiens”.",
                      style: TextStyle(fontSize: 12, color: AppColors.white),
                    ),
                    const SizedBox(height: 12),

                    // NÚT THAM GIA NGAY (Có tương tác)
                    GestureDetector(
                      onTap: () {
                        // Thêm logic chuyển màn hình cho nút Tham gia ngay tại đây
                        print("Tương tác: Bấm nút Tham gia ngay");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Tham gia ngay",
                          style: TextStyle(
                            // Dùng màu tím đậm cho chữ
                            color: Color(0xFF6D28D9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- DANH SÁCH HOẠT ĐỘNG ---
              _buildActivityItem(
                avatarText: "ST",
                name: "Sếp Tuấn",
                action: "đã đọc xong",
                time: "2h trước",
                bookImage:
                    "assets/books/zero_to_one.png", // Thay bằng đường dẫn ảnh của bạn
                bookTitle: "Zero to One",
                rating: 4.5,
                // Tương tác khi chạm tên người dùng
                onTapUser: () => print("Tương tác: Bấm tên Sếp Tuấn"),
                // Tương tác khi chạm sách
                onTapBook: () => print("Tương tác: Bấm sách Zero to One"),
              ),

              const SizedBox(height: 16),

              _buildActivityItem(
                avatarText: "LC",
                name: "Lan Chi",
                action: "thêm vào kệ",
                time: "5h trước",
                bookImage:
                    "assets/books/rung_nauy.png", // Thay bằng đường dẫn ảnh của bạn
                bookTitle: "Rừng Na Uy",
                rating: 3.5,
                onTapUser: () => print("Tương tác: Bấm tên Lan Chi"),
                onTapBook: () => print("Tương tác: Bấm sách Rừng Na Uy"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget: Hiển thị Đánh giá Sao (5 sao) ---
  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      IconData icon;
      Color color = AppColors.amber;
      if (i < fullStars) {
        icon = Icons.star;
      } else if (i == fullStars && halfStar) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
        color = AppColors.textGrey.withOpacity(0.5);
      }
      stars.add(Icon(icon, color: color, size: 12));
    }

    return Row(children: stars);
  }

  // --- Widget: Mục Hoạt động (Activity Item) ---
  Widget _buildActivityItem({
    required String avatarText,
    required String name,
    required String action,
    required String time,
    required String bookImage,
    required String bookTitle,
    required double rating,
    required VoidCallback onTapUser,
    required VoidCallback onTapBook,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Avatar và Tên/Hoạt động (Vùng chạm Tên người dùng)
          InkWell(
            onTap: onTapUser, // Tương tác: Chạm vào tên người dùng
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.textGrey.withOpacity(0.3),
                    child: Text(
                      avatarText,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tên người dùng và Hành động
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // Gộp tên và hành động
                        "$name $action",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2. Book preview và Rating (Vùng chạm Sách)
          InkWell(
            onTap: onTapBook, // Tương tác: Chạm vào sách
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  // Hình ảnh Sách
                  Container(
                    width: 55,
                    height: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(bookImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tiêu đề sách và Rating
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStarRating(rating), // Hiển thị rating 5 sao
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
