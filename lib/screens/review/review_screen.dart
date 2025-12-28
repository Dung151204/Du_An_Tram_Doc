import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final PageController _pageController = PageController();
  List<DocumentSnapshot> _allCards = [];
  List<DocumentSnapshot> _currentSessionCards = [];
  bool _initialized = false;
  bool _isFinished = false;
  bool _canReviewToday = true;
  String? _lastReviewDate;

  @override
  void initState() {
    super.initState();
    _checkAndLoadCards();
  }

  Future<void> _checkAndLoadCards() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Lấy ngày review cuối cùng từ Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final lastReview = userDoc.data()?['lastReviewDate'] as String?;

    // 🔥 Logic: reset vào 5h sáng
    final now = DateTime.now();
    final today5AM = DateTime(now.year, now.month, now.day, 5, 0);
    final effectiveDate = now.isBefore(today5AM)
        ? DateTime(now.year, now.month, now.day - 1).toIso8601String().split('T')[0]
        : now.toIso8601String().split('T')[0];

    final canReview = lastReview != effectiveDate;

    setState(() {
      _lastReviewDate = lastReview;
      _canReviewToday = canReview;
    });

    // 🔥 LUÔN fetch thẻ mới từ Firebase (cho cả ngày mới và ôn lại)
    await _loadCards();

    setState(() {
      _initialized = true;
    });
  }

  Future<void> _loadCards() async {
    // 🔥 Luôn fetch mới từ Firebase để có thẻ cập nhật nhất
    final snapshot = await FirebaseFirestore.instance.collectionGroup('flashcards').get();
    setState(() {
      _allCards = List.from(snapshot.docs);

      // Chỉ set currentSessionCards nếu đang cho phép review
      if (_canReviewToday) {
        _currentSessionCards = List.from(_allCards);
        _currentSessionCards.shuffle(); // 🔥 Đảo thẻ
      }
    });
  }

  void _handleAssessment(String bookId, String cardId, String level, int index) async {
    await DatabaseService().updateFlashcardLevel(bookId, cardId, level);

    setState(() {
      _currentSessionCards.removeAt(index);
      if (_currentSessionCards.isEmpty) {
        _isFinished = true;
      }
    });

    // Reset PageView về trang đầu
    if (_currentSessionCards.isNotEmpty) {
      _pageController.jumpToPage(0);
    }
  }

  void _restartSession() {
    setState(() {
      _currentSessionCards = List.from(_allCards);
      _currentSessionCards.shuffle(); // 🔥 Đảo thẻ lại
      _isFinished = false;
      _canReviewToday = true; // Cho phép ôn lại
    });
    _pageController.jumpToPage(0);
  }

  Future<void> _finishAndExit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Lưu ngày hoàn thành review (theo logic 5h sáng)
      final now = DateTime.now();
      final today5AM = DateTime(now.year, now.month, now.day, 5, 0);
      final effectiveDate = now.isBefore(today5AM)
          ? DateTime(now.year, now.month, now.day - 1).toIso8601String().split('T')[0]
          : now.toIso8601String().split('T')[0];

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'lastReviewDate': effectiveDate}, SetOptions(merge: true));

      // Set trạng thái đã xong hôm nay
      setState(() {
        _canReviewToday = false;
        _isFinished = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // Nếu đã review hôm nay → hiện màn chờ
    if (!_canReviewToday) {
      return _buildWaitScreen();
    }

    // Nếu hoàn thành → hiện màn kết thúc
    if (_isFinished) {
      return _buildFinishedScreen();
    }

    // Màn hình chính
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Ôn tập", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_currentSessionCards.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: Text(
                  "${_currentSessionCards.length} thẻ",
                  style: const TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      body: _buildCardView(),
    );
  }

  Widget _buildCardView() {
    return SafeArea(
      bottom: true,
      child: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _currentSessionCards.length,
        itemBuilder: (context, index) {
          final data = _currentSessionCards[index].data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 110),
            child: FlipCard(
              key: ValueKey(_currentSessionCards[index].id),
              direction: FlipDirection.HORIZONTAL,
              front: _cardSide(
                data['question'] ?? "",
                "CÂU HỎI",
                const Color(0xFFF97316),
              ),
              back: Column(
                children: [
                  Expanded(
                    child: _cardSide(
                      data['answer'] ?? "",
                      "ĐÁP ÁN",
                      const Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBottomButtons(_currentSessionCards[index], index),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _cardSide(String text, String label, Color labelColor) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Stack(
        children: [
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: labelColor, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Positioned(
            bottom: 25,
            left: 0,
            right: 0,
            child: Text("chạm để lật", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(DocumentSnapshot doc, int index) {
    final cardId = doc.id;
    final bookId = doc.reference.parent.parent!.id;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _scoreButton("Khó", Colors.redAccent, bookId, cardId, 'hard', index),
          _scoreButton("Vừa", Colors.blueAccent, bookId, cardId, 'good', index),
          _scoreButton("Dễ", Colors.greenAccent, bookId, cardId, 'easy', index),
        ],
      ),
    );
  }

  Widget _scoreButton(String label, Color color, String bookId, String cardId, String level, int index) {
    return InkWell(
      onTap: () => _handleAssessment(bookId, cardId, level, index),
      child: Container(
        width: 85,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Center(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildFinishedScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
              const SizedBox(height: 20),
              const Text(
                "Hoàn thành!",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Bạn đã ôn xong ${_allCards.length} thẻ",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Nút "Kết thúc"
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _finishAndExit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    "Kết thúc",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitScreen() {
    // Tính thời gian đến 5h sáng ngày mai
    final now = DateTime.now();
    final tomorrow5AM = now.hour >= 5
        ? DateTime(now.year, now.month, now.day + 1, 5, 0)
        : DateTime(now.year, now.month, now.day, 5, 0);
    final hoursLeft = tomorrow5AM.difference(now).inHours;
    final minutesLeft = tomorrow5AM.difference(now).inMinutes % 60;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Ôn tập", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.schedule, color: Colors.orangeAccent, size: 80),
              const SizedBox(height: 20),
              const Text(
                "Hẹn gặp lại!",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Bạn đã hoàn thành ôn tập hôm nay",
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    FutureBuilder<int>(
                      future: _getTotalCardsCount(),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return Text(
                          "Tổng số thẻ: $count",
                          style: const TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Quay lại sau: ${hoursLeft}h ${minutesLeft}p (5h sáng)",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Nút "Ôn tập lại" - Xào thẻ
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _restartSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    "Ôn tập lại",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _getTotalCardsCount() async {
    final snapshot = await FirebaseFirestore.instance.collectionGroup('flashcards').get();
    return snapshot.docs.length;
  }
}