import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../book_details/book_detail_screen.dart'; // Màn hình chi tiết sách đang đọc
import '../book_details/book_preview_screen.dart'; // Màn hình xem trước sách khám phá (MỚI)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Biến để theo dõi Tab đang chọn (Mặc định là 'reading')
  String _currentTab = 'reading';

  // --- DỮ LIỆU ĐANG ĐỌC ---
  final List<Map<String, dynamic>> _readingBooks = [
    {
      "title": "Nhà Giả Kim",
      "author": "Paulo Coelho",
      "progress": 65,  // Số trang đã đọc
      "total": 115,    // Tổng số trang
      "image": "assets/images/nha_gia_kim.jpg",
      "streak": 5,
    },
    {
      "title": "Đắc Nhân Tâm",
      "author": "Dale Carnegie",
      "progress": 98,
      "total": 211,
      "image": "assets/images/dac_nhan_tam.jpg",
      "streak": 5,
    },
  ];

  // --- DỮ LIỆU KHÁM PHÁ (MỚI) ---
  final List<Map<String, dynamic>> _discoveryBooks = [
    {
      "title": "Tư duy nhanh và chậm",
      "author": "Daniel Kahneman",
      "rating": 4.7,
      "total": 400,
      "color": const Color(0xFFC2410C), // Màu nâu cam
      "image": null, // Chưa có ảnh thì dùng màu
    },
    {
      "title": "Sapiens",
      "author": "Yuval Noah Harari",
      "rating": 4.9,
      "total": 512,
      "color": const Color(0xFFEAB308), // Màu vàng
      "image": null,
    },
    {
      "title": "Nguyên lý 80/20",
      "author": "Richard Koch",
      "rating": 4.5,
      "total": 300,
      "color": const Color(0xFF3B82F6), // Màu xanh dương
      "image": null,
    },
    {
      "title": "Dám bị ghét",
      "author": "Kishimi Ichiro",
      "rating": 4.8,
      "total": 350,
      "color": const Color(0xFF1E6F86), // Màu xanh cổ vịt
      "image": null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER
            _buildHeader(),

            // 2. NỘI DUNG CHÍNH
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab Switcher
                    _buildTabSwitcher(),
                    const SizedBox(height: 24),

                    // --- NỘI DUNG TAB: ĐANG ĐỌC ---
                    if (_currentTab == 'reading') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tủ sách (${_readingBooks.length})",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Danh sách sách đang đọc
                      ..._readingBooks.map((book) => _buildReadingBookCard(book)),

                      const SizedBox(height: 80), // Khoảng trống dưới cùng
                    ]

                    // --- NỘI DUNG TAB: KHÁM PHÁ (MỚI) ---
                    else ...[
                      const Text(
                        "✨ Gợi ý cho bạn",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 16),

                      // Lưới sách 2 cột
                      GridView.builder(
                        shrinkWrap: true, // Để Grid nằm gọn trong SingleChildScrollView
                        physics: const NeverScrollableScrollPhysics(), // Tắt cuộn riêng của Grid
                        itemCount: _discoveryBooks.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 cột
                          crossAxisSpacing: 16, // Khoảng cách ngang
                          mainAxisSpacing: 16, // Khoảng cách dọc
                          childAspectRatio: 0.65, // Tỷ lệ thẻ sách (cao/rộng)
                        ),
                        itemBuilder: (context, index) {
                          return _buildDiscoveryBookCard(_discoveryBooks[index]);
                        },
                      ),
                      const SizedBox(height: 80),
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

  // --- CÁC WIDGET CON ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("CHÀO BUỔI TỐI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textGrey, letterSpacing: 1)),
              SizedBox(height: 4),
              Text("Tiến Dũng", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ],
          ),
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
            child: const Center(child: Text("TD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          )
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Expanded(child: GestureDetector(onTap: () => setState(() => _currentTab = 'reading'), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: _currentTab == 'reading' ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: Center(child: Text("Đang đọc", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _currentTab == 'reading' ? Colors.white : AppColors.textGrey)))))),
          Expanded(child: GestureDetector(onTap: () => setState(() => _currentTab = 'discovery'), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: _currentTab == 'discovery' ? AppColors.amber : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: Center(child: Text("Khám phá", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _currentTab == 'discovery' ? Colors.white : AppColors.textGrey)))))),
        ],
      ),
    );
  }

  // Widget Thẻ sách Đang đọc (Nằm ngang)
  Widget _buildReadingBookCard(Map<String, dynamic> book) {
    double progressPercent = book['progress'] / book['total'];
    int percentDisplay = (progressPercent * 100).toInt();

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none, alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(book['image'], width: 70, height: 100, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width:70, height:100, color:Colors.grey))),
                Positioned(bottom: -8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white, width: 2)), child: Text("$percentDisplay%", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(book['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)), const SizedBox(height: 4), Text(book['author'], style: const TextStyle(fontSize: 12, color: AppColors.textGrey)), const SizedBox(height: 16), ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progressPercent, backgroundColor: Colors.grey.shade100, color: Colors.orange.shade600, minHeight: 6)), const SizedBox(height: 12), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${book['total']} trang", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textGrey)), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6)), child: Row(children: [const Icon(LucideIcons.flame, size: 12, color: Colors.orange), const SizedBox(width: 2), Text("${book['streak']}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange))]))])]))
          ],
        ),
      ),
    );
  }

  // --- WIDGET MỚI: Thẻ sách Khám Phá (Nằm dọc) ---
  Widget _buildDiscoveryBookCard(Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () {
        // Chuyển sang màn hình Preview
        Navigator.push(context, MaterialPageRoute(builder: (context) => BookPreviewScreen(book: book)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Phần Ảnh/Màu bìa
            Expanded(
              flex: 3,
              child: Hero(
                tag: book['title'],
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: book['color'], // Màu nền (Nâu/Vàng/Xanh)
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          book['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Serif'),
                        ),
                      ),
                      const Positioned(top: 0, right: 0, child: Icon(LucideIcons.heart, color: Colors.white54, size: 20)),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Phần Thông tin dưới
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(book['author'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text("${book['rating']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}