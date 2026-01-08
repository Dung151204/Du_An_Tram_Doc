import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/book_model.dart';
import '../../services/ai_service.dart';
import '../../services/database_service.dart';

class PhysicalReadingTracker extends StatefulWidget {
  final BookModel book;
  const PhysicalReadingTracker({super.key, required this.book});

  @override
  State<PhysicalReadingTracker> createState() => _PhysicalReadingTrackerState();
}

class _PhysicalReadingTrackerState extends State<PhysicalReadingTracker> {
  late TextEditingController _pageController;
  bool _isGeneratingAI = false;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(text: widget.book.currentPage.toString());
  }

  // Hàm cập nhật tiến độ & Gọi AI
  void _updateProgressAndAskAI() async {
    int newPage = int.tryParse(_pageController.text) ?? widget.book.currentPage;

    // 1. Cập nhật tiến độ lên Firebase
    await FirebaseFirestore.instance.collection('books').doc(widget.book.id).update({
      'currentPage': newPage,
    });

    if (!mounted) return;

    // 2. Hỏi người dùng
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đã lưu tiến độ!"),
        content: Text("Bạn vừa đọc đến trang $newPage. Muốn AI tạo câu hỏi ôn tập không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Thôi")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isGeneratingAI = true);

              // Gọi AI (Giả sử bạn đã có hàm này trong AIService)
              // Nếu chưa có, bạn có thể comment dòng dưới lại để tránh lỗi tạm thời
              try {
                final quiz = await AIService().generateQuizFromProgress(widget.book, newPage);
                await DatabaseService().saveAICreatedFlashcards(widget.book.id!, quiz);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Đã tạo câu hỏi AI!")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi AI: $e")));
              }

              setState(() => _isGeneratingAI = false);
            },
            child: const Text("Tạo câu hỏi AI"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Hôm nay bạn đọc đến trang nào?", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
              decoration: const InputDecoration(border: InputBorder.none, hintText: "0"),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isGeneratingAI
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _updateProgressAndAskAI,
                child: const Text("Lưu & Review AI"),
              ),
            )
          ],
        ),
      ),
    );
  }
}