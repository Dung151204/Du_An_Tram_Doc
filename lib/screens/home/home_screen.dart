import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Biến để theo dõi Tab đang chọn (Mặc định là 'reading')
  String _currentTab = 'reading';

  // Dữ liệu giả lập (Sau này sẽ lấy từ Firebase)
  final List<Map<String, dynamic>> _books = [
    {
      "title": "Tư duy nhanh và chậm",
      "author": "Daniel Kahneman",
      "progress": 65,
      "total": 400,
      "color": Colors.amber.shade700, // Màu bìa giả lập
    },
    {
      "title": "Deep Work",
      "author": "Cal Newport",
      "progress": 120,
      "total": 300,
      "color": Colors.yellow.shade800,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. PHẦN ĐẦU TRANG (Header)
            _buildHeader(),

            // 2. NỘI DUNG CHÍNH (Cuộn được)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab Chuyển đổi (Đang đọc / Khám phá)
                    _buildTabSwitcher(),
                    const SizedBox(height: 24),

                    // Nội dung thay đổi theo Tab
                    if (_currentTab == 'reading') ...[
                      // Tiêu đề section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tủ sách (${_books.length})",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Danh sách sách (Map từ dữ liệu ra Widget)
                      ..._books.map((book) => _buildBookCard(book)),

                      // Khoảng trống dưới cùng để không bị nút (+) che mất
                      const SizedBox(height: 80),
                    ] else ...[
                      // Giao diện Tab Khám phá (Làm sau)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Text("Tính năng Khám phá đang phát triển..."),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON (Tách ra cho gọn code) ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "CHÀO BUỔI TỐI",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Tiến Dũng",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "TD",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Nút Đang đọc
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 'reading'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentTab == 'reading' ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Đang đọc",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _currentTab == 'reading' ? Colors.white : AppColors.textGrey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Nút Khám phá
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 'discovery'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentTab == 'discovery' ? AppColors.amber : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Khám phá",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _currentTab == 'discovery' ? Colors.white : AppColors.textGrey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    double progressPercent = book['progress'] / book['total'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ảnh bìa (Giả lập bằng màu)
          Container(
            width: 70,
            height: 100,
            decoration: BoxDecoration(
              color: book['color'],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (book['color'] as Color).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(LucideIcons.book, color: Colors.white24, size: 30),
            ),
          ),
          const SizedBox(width: 16),
          // Thông tin sách
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif', // Font có chân cho tên sách
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book['author'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 12),

                // Thanh tiến độ
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: Colors.grey.shade100,
                    color: AppColors.amber,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),

                // Số trang & Streak
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${book['progress']} trang",
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textGrey
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.flame, size: 12, color: Colors.orange),
                          const SizedBox(width: 2),
                          const Text(
                            "5",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}