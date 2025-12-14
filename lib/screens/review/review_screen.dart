import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _showAnswer = false; // false = Mặt trước, true = Mặt sau

  @override
  Widget build(BuildContext context) {
    // Màu nền đổi theo trạng thái: Sáng (Câu hỏi) - Tối (Đáp án)
    final backgroundColor = _showAnswer ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final textColor = _showAnswer ? Colors.white : AppColors.textDark;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ôn tập",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  if (_showAnswer)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24)),
                      child: const Text("2 thẻ", style: TextStyle(color: AppColors.amber, fontSize: 12)),
                    )
                ],
              ),
            ),

            // THẺ FLASHCARD (Hiệu ứng lật)
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => setState(() => _showAnswer = !_showAnswer),
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: _showAnswer ? pi : 0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, double val, child) {
                      bool isFront = val < (pi / 2);
                      return Transform(
                        transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(val),
                        alignment: Alignment.center,
                        child: isFront
                            ? _buildCardSide(isFront: true)
                            : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(pi),
                          child: _buildCardSide(isFront: false),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // NÚT ĐÁNH GIÁ (Chỉ hiện khi lật mặt sau)
            SizedBox(
              height: 100,
              child: _showAnswer
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildRateBtn("Khó", Colors.red.shade900, Colors.red),
                    const SizedBox(width: 12),
                    _buildRateBtn("Vừa", Colors.blue.shade900, Colors.blue),
                    const SizedBox(width: 12),
                    _buildRateBtn("Dễ", const Color(0xFF064E3B), Colors.green),
                  ],
                ),
              )
                  : null,
            ),
            const SizedBox(height: 30), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildCardSide({required bool isFront}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isFront ? "CÂU HỎI" : "ĐÁP ÁN",
            style: TextStyle(
              color: isFront ? AppColors.amber : Colors.green,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isFront ? "Hệ thống trong một tư duy là gì?" : "Hoạt động tự động, nhanh chóng và ít nỗ lực.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
          if (isFront) ...[
            const Spacer(),
            Text("chạm để lật", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ]
        ],
      ),
    );
  }

  Widget _buildRateBtn(String text, Color bg, Color border) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: bg.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border.withOpacity(0.5)),
        ),
        child: Center(
            child: Text(text, style: TextStyle(color: border, fontWeight: FontWeight.bold))),
      ),
    );
  }
}