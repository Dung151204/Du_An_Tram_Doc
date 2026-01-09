import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    // --- LOGIC TỰ ĐỘNG HOÀN THÀNH ---
    if (newPage == _totalPages && !_hasMarkedAsCompleted && widget.book != null) {
      _hasMarkedAsCompleted = true;

      // SỬA: Cập nhật đúng key 'readingStatus'
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("⚠️ AI chưa nghĩ ra câu hỏi, hãy đọc thêm chút nữa!")),
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
    final String displayContent = widget.book?.content ?? widget.content ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayTitle, style: const TextStyle(color: Colors.black, fontSize: 16)),
            if (widget.book != null)
              Text("Trang $_currentPageDisplay / $_totalPages", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
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

      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 80),
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
            if (widget.book != null)
              const Text("--- Hết ---", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}