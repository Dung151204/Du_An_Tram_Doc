import 'package:flutter/material.dart';
import 'manual_add_screen.dart'; // Import màn hình nhập tay gốc
import 'search_add_screen.dart'; // [MỚI] Import màn hình tìm kiếm
import 'qr_scan_screen.dart';    // [MỚI] Import màn hình quét mã

class AddBookSheet extends StatelessWidget {
  const AddBookSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh gạch ngang nhỏ trên cùng (Handle bar)
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            "Thêm sách mới",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),

          // Hàng chứa 2 nút tròn: Quét mã & Tìm kiếm
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOption(
                context,
                icon: Icons.qr_code_scanner,
                label: "Quét mã",
                color: Colors.orange.shade50,
                iconColor: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  // [LOGIC] Chuyển sang màn hình quét mã
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QRScanScreen()),
                  );
                },
              ),
              _buildOption(
                context,
                icon: Icons.search,
                label: "Tìm kiếm",
                color: Colors.blue.shade50,
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  // [LOGIC] Chuyển sang màn hình tìm kiếm
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchAddScreen()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- NÚT NHẬP THỦ CÔNG ---
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Đóng bảng chọn trước
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManualAddScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      // [FIX] Sửa withOpacity thành withValues
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    )
                  ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.edit_note, size: 24, color: Colors.black87),
                  SizedBox(width: 10),
                  Text(
                      "Nhập thủ công",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)
                  ),
                ],
              ),
            ),
          ),
          // ---------------------------------------------------

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget vẽ nút tròn (không thay đổi)
  Widget _buildOption(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}