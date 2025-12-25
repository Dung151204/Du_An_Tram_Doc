import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/constants/app_colors.dart';

// 1. Thẻ sách nằm ngang (Dùng cho tab Đang đọc)
class ReadingBookCard extends StatelessWidget {
  final Map<String, dynamic> book; // Sau này sẽ đổi thành BookModel
  final VoidCallback onTap;

  const ReadingBookCard({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double progressPercent = book['progress'] / book['total'];
    int percentDisplay = (progressPercent * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none, alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(book['image'], width: 70, height: 100, fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => Container(width:70, height:100, color: Colors.grey.shade300)),
                ),
                Positioned(
                    bottom: -8,
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white, width: 2)),
                        child: Text("$percentDisplay%", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(book['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(book['author'], style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  const SizedBox(height: 16),
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progressPercent, backgroundColor: Colors.grey.shade100, color: Colors.orange.shade600, minHeight: 6)),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("${book['total']} trang", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
                    if (book.containsKey('streak'))
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6)),
                          child: Row(children: [const Icon(LucideIcons.flame, size: 12, color: Colors.orange), const SizedBox(width: 2), Text("${book['streak']}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange))]))
                  ])
                ]))
          ],
        ),
      ),
    );
  }
}

// 2. Thẻ sách nằm dọc (Dùng cho tab Khám phá)
class DiscoveryBookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onTap;

  const DiscoveryBookCard({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            Expanded(
              flex: 3,
              child: Hero(
                tag: book['title'], // Hero animation
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: book['color'] ?? AppColors.primary,
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
                    ],
                  ),
                ),
              ),
            ),
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
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.amber),
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