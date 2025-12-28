import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/database_service.dart';
import '../book_details/book_detail_screen.dart';
import '../book_details/book_preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTab = 'reading';

  // Dữ liệu giả tab Khám phá
  final List<Map<String, dynamic>> _discoveryBooks = [
    {"title": "Nhà Giả Kim", "author": "Paulo Coelho", "rating": 4.8, "total": 228, "color": const Color(0xFFF59E0B)},
    {"title": "Đắc Nhân Tâm", "author": "Dale Carnegie", "rating": 4.9, "total": 320, "color": const Color(0xFFEF4444)},
    {"title": "Dám Bị Ghét", "author": "Kishimi Ichiro", "rating": 4.5, "total": 300, "color": const Color(0xFF3B82F6)},
    {"title": "Sapiens", "author": "Yuval Noah Harari", "rating": 4.7, "total": 512, "color": const Color(0xFF10B981)},
  ];

  @override
  Widget build(BuildContext context) {
    // SỬA: Giữ lại Scaffold để có màu nền, nhưng XÓA bottomNavigationBar
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      // --- PHẦN BODY GIỮ NGUYÊN ---
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTabSwitcher(),
                    const SizedBox(height: 24),

                    if (_currentTab == 'reading')
                      StreamBuilder<List<BookModel>>(
                        stream: DatabaseService().getBooks(),
                        builder: (context, snapshot) {
                          int count = snapshot.hasData ? snapshot.data!.length : 0;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Tủ sách ($count)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                              const SizedBox(height: 16),
                              if (snapshot.hasData)
                                ...snapshot.data!.map((book) => _buildRealBookCard(book)),
                            ],
                          );
                        },
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Gợi ý cho bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 16),
                          ..._discoveryBooks.map((book) => _buildRealBookCardFromMap(book)),
                        ],
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON (GIỮ NGUYÊN KHÔNG ĐỔI) ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Chào buổi tối", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
            const SizedBox(height: 4),
            const Text("Tiến Dũng", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))
          ]),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
            child: const Text("TD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(6),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _currentTab = 'reading'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _currentTab == 'reading' ? const Color(0xFF1E293B) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text("Đang đọc", textAlign: TextAlign.center, style: TextStyle(color: _currentTab == 'reading' ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _currentTab = 'discovery'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _currentTab == 'discovery' ? const Color(0xFF1E293B) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text("Khám phá", textAlign: TextAlign.center, style: TextStyle(color: _currentTab == 'discovery' ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildRealBookCard(BookModel book) {
    double percent = book.totalPages > 0 ? (book.currentPage / book.totalPages) : 0.0;
    int percentInt = (percent * 100).toInt();

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailScreen(book: book))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 5)
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80, height: 110,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: book.imageUrl.isNotEmpty && book.imageUrl.startsWith('http')
                    ? Image.network(book.imageUrl, fit: BoxFit.cover)
                    : Center(child: Icon(Icons.menu_book, color: book.coverColor ?? Colors.orange, size: 40)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(book.author, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(value: percent, backgroundColor: Colors.grey.shade100, color: Colors.orange, minHeight: 6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                      Text(" $percentInt%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("${book.totalPages} trang", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade300)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRealBookCardFromMap(Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookPreviewScreen(book: book))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 80, height: 110,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: book['color']),
              alignment: Alignment.center,
              child: const Icon(Icons.menu_book, color: Colors.white, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(book['author'], style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                  const SizedBox(height: 20),
                  Row(children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    Text(" ${book['rating']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text("${book['total']} trang", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ])
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}