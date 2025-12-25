import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../reading/reading_screen.dart';
import 'rating_screen.dart';

class BookPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookPreviewScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: book['color'] ?? const Color(0xFFC2410C)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => Navigator.pop(context)),
                      IconButton(icon: const Icon(Icons.star, color: Colors.white), onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RatingScreen(book: book)));
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Hero(
                  tag: book['title'],
                  child: Container(
                    width: 160, height: 240,
                    decoration: BoxDecoration(color: book['color'], borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)]),
                    alignment: Alignment.center,
                    child: Text(book['title'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(book['title'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(book['author'], style: const TextStyle(fontSize: 16, color: Colors.white70)),
                const Spacer(),
                Container(
                  width: double.infinity, margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.menu_book, color: Colors.white),
                      label: const Text("Đọc thử", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ReadingScreen(
                          bookTitle: book['title'],
                          content: "Nội dung giả lập của sách ${book['title']}...",
                        )));
                      },
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}