import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import 'manual_add_screen.dart';
import 'qr_scan_screen.dart';
import 'search_book_screen.dart';

class AddBookSheet extends StatelessWidget {
  const AddBookSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Thanh nắm kéo
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Text("Thêm sách mới", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 32),

          Row(
            children: [
              _buildBtn(context, LucideIcons.scanLine, "Quét mã", Colors.amber.shade100.withOpacity(0.5), Colors.orange, () {
                Navigator.pop(context); // 1. Đóng cái menu lại trước
                // 2. Mở màn hình Quét QR lên
                Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScanScreen()));
              }),
              const SizedBox(width: 16),

              // Nút Tìm kiếm
              _buildBtn(context, LucideIcons.search, "Tìm kiếm", Colors.blue.shade100.withOpacity(0.5), Colors.blue, () {
                Navigator.pop(context); // Đóng menu
                // Chuyển sang màn hình Tìm kiếm
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchBookScreen()));
              }),
            ],
          ),
          const SizedBox(height: 20),

          // Nút Nhập thủ công
          // ...
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Đóng menu
              // Chuyển sang màn hình mới
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualAddScreen()));
            },
// ...
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.edit3, size: 20, color: AppColors.textDark),
                  SizedBox(width: 10),
                  Text("Nhập thủ công", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBtn(BuildContext context, IconData icon, String label, Color bg, Color iconColor, VoidCallback onPress) {
    return Expanded(
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          height: 130,
          decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(24)
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor, size: 28)
                ),
                const SizedBox(height: 16),
                Text(label, style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.bold)),
              ]
          ),
        ),
      ),
    );
  }
}