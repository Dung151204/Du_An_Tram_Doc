import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';

class AddBookSheet extends StatelessWidget {
  const AddBookSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Text("Thêm sách mới", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 32),

          Row(
            children: [
              // Nút Quét mã (Chưa có lệnh chuyển trang)
              _buildBtn(context, LucideIcons.scanLine, "Quét mã", Colors.amber.shade50, Colors.amber, () {}),
              const SizedBox(width: 16),
              // Nút Tìm kiếm (Chưa có lệnh chuyển trang)
              _buildBtn(context, LucideIcons.search, "Tìm kiếm", Colors.blue.shade50, Colors.blue, () {}),
            ],
          ),
          const SizedBox(height: 16),

          // Nút Nhập thủ công (Chưa có lệnh chuyển trang)
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.edit3, size: 20, color: AppColors.textGrey),
                  SizedBox(width: 8),
                  Text("Nhập thủ công", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBtn(BuildContext context, IconData icon, String label, Color bg, Color color, VoidCallback onPress) {
    return Expanded(
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          height: 120,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(icon, color: color)),
                const SizedBox(height: 12),
                Text(label, style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
              ]
          ),
        ),
      ),
    );
  }
}