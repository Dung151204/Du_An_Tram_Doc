import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../services/ai_service.dart';
import '../../services/database_service.dart';

class ReadingScreen extends StatefulWidget {
  final BookModel? book;
  final String? bookTitle;
  final String? content;

  const ReadingScreen({
    super.key,
    this.book,
    this.bookTitle,
    this.content,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPageDisplay = 1;
  int _totalPages = 1;
  bool _isGeneratingAI = false;
  bool _hasMarkedAsCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _totalPages = widget.book!.totalPages > 0 ? widget.book!.totalPages : 1;
      _currentPageDisplay = widget.book!.currentPage > 0 ? widget.book!.currentPage : 1;
    }
    _scrollController.addListener(_updatePageOnScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updatePageOnScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _updatePageOnScroll() {
    if (!_scrollController.hasClients) return;

    double progress = _scrollController.offset / _scrollController.position.maxScrollExtent;
    if (progress > 1) progress = 1;
    if (progress < 0) progress = 0;

    int newPage = (progress * _totalPages).ceil();
    if (newPage < 1) newPage = 1;

    if (newPage != _currentPageDisplay) {
      setState(() {
        _currentPageDisplay = newPage;
      });
    }

    if (newPage == _totalPages && !_hasMarkedAsCompleted && widget.book != null) {
      _hasMarkedAsCompleted = true;

      DatabaseService().updateBook(widget.book!.id!, {
        'readingStatus': 'completed',
        'currentPage': _totalPages
      }).then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🎉 Chúc mừng! Bạn đã hoàn thành cuốn sách."),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    }
  }

  void _showAddContentDialog(String targetDocId) {
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tiếp tục viết nội dung"),
        content: TextField(
          controller: contentController,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: "Dán nội dung mới vào đây...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (contentController.text.trim().isNotEmpty) {
                await DatabaseService().appendBookContent(
                    targetDocId,
                    contentController.text.trim()
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✅ Đã cập nhật nội dung mới!")),
                  );
                }
              }
            },
            child: const Text("Cập nhật"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndAskAI() async {
    if (widget.book == null) return;
    setState(() => _isGeneratingAI = true);
    try {
      await FirebaseFirestore.instance.collection('books').doc(widget.book!.id).update({
        'currentPage': _currentPageDisplay,
      });
      final quiz = await AIService().generateQuizFromProgress(widget.book!, _currentPageDisplay);
      if (quiz.isNotEmpty) {
        await DatabaseService().saveAICreatedFlashcards(widget.book!.id!, quiz);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ AI đã tạo ${quiz.length} câu hỏi cho trang $_currentPageDisplay!")),
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isGeneratingAI = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayTitle = widget.book?.title ?? widget.bookTitle ?? "Đọc sách";
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

    final bookData = widget.book?.toMap();
    // LUÔN DÙNG ID GỐC ĐỂ LẮNG NGHE RATING VÀ BÌNH LUẬN
    final String targetDocId = (bookData != null && bookData['originalBookId'] != null)
        ? bookData['originalBookId']
        : (widget.book?.id ?? "");

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('books').doc(targetDocId).snapshots(),
          builder: (context, snapshot) {
            double rating = widget.book?.rating ?? 0.0;
            int reviewsCount = widget.book?.reviewsCount ?? 0;

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              // Lấy Rating chung từ sách gốc trên server để tất cả mọi người đều thấy nhảy số
              rating = (data['rating'] ?? 0.0).toDouble();
              reviewsCount = (data['reviewsCount'] ?? 0);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayTitle, style: const TextStyle(color: Colors.black, fontSize: 16)),
                Row(
                  children: [
                    Text("Trang $_currentPageDisplay / $_totalPages", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    Text(" ${rating.toStringAsFixed(1)} ($reviewsCount)", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            );
          },
        ),
        backgroundColor: const Color(0xFFFFFBF0),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      floatingActionButton: widget.book != null
          ? FloatingActionButton.extended(
        onPressed: _isGeneratingAI ? null : _saveAndAskAI,
        backgroundColor: Colors.deepPurple,
        icon: _isGeneratingAI
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(
          _isGeneratingAI ? "Đang tạo..." : "Hỏi AI (Trang $_currentPageDisplay)",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
          : null,

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('books').doc(targetDocId).snapshots(),
        builder: (context, snapshot) {
          String displayContent = widget.book?.content ?? widget.content ?? "";
          bool isRealOwner = false;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            displayContent = data['content'] ?? displayContent;

            final String? realOwnerId = data['userId'];
            isRealOwner = currentUid != null && realOwnerId == currentUid;
          }

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 120),
            child: Column(
              children: [
                Text(
                  displayContent.isNotEmpty ? displayContent : "Chưa có nội dung.",
                  style: const TextStyle(
                      fontSize: 18,
                      height: 1.8,
                      color: AppColors.textDark,
                      fontFamily: 'Serif'
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 50),
                if (widget.book != null) ...[
                  const Text("--- Hết ---", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 30),

                  if (isRealOwner)
                    ElevatedButton.icon(
                      onPressed: () => _showAddContentDialog(targetDocId),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("THÊM NỘI DUNG"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}