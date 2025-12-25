import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../services/database_service.dart';

class ManualAddScreen extends StatefulWidget {
  const ManualAddScreen({super.key});

  @override
  State<ManualAddScreen> createState() => _ManualAddScreenState();
}

class _ManualAddScreenState extends State<ManualAddScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  final _descController = TextEditingController();
  final _contentController = TextEditingController(); // <--- MỚI: Controller cho nội dung sách

  File? _selectedImage;
  bool _isLoading = false;
  late int _randomColor;

  @override
  void initState() {
    super.initState();
    _randomColor = [0xFFC2410C, 0xFF1E6F86, 0xFFEAB308, 0xFF3B82F6][Random().nextInt(4)];
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) setState(() => _selectedImage = File(image.path));
    } catch (e) { print(e); }
  }

  Future<void> _handleSaveBook() async {
    if (_titleController.text.trim().isEmpty || _authorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thiếu tên sách hoặc tác giả!'), backgroundColor: Colors.orange));
      return;
    }

    // Kiểm tra xem có nhập nội dung không (Tùy chọn)
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu ý: Bạn chưa nhập nội dung sách để đọc!'), backgroundColor: Colors.amber));
    }

    setState(() => _isLoading = true);

    try {
      String bookId = DateTime.now().millisecondsSinceEpoch.toString();
      String imagePath = _selectedImage != null ? _selectedImage!.path : "";

      final newBook = BookModel(
        id: bookId,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description: _descController.text.trim(),
        content: _contentController.text, // <--- LƯU NỘI DUNG VÀO ĐÂY
        totalPages: int.tryParse(_pagesController.text) ?? 0,
        imageUrl: imagePath,
        colorValue: _randomColor,
        createdAt: DateTime.now(),
      );

      await DatabaseService().addBook(newBook);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Đã thêm sách và nội dung!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(LucideIcons.x, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("Nhập sách mới", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. Ảnh
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 140, height: 190,
                decoration: BoxDecoration(
                  color: _selectedImage == null ? Color(_randomColor) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: _selectedImage != null ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) : null,
                ),
                child: _selectedImage == null ? const Center(child: Icon(LucideIcons.imagePlus, color: Colors.white, size: 32)) : null,
              ),
            ),
            const SizedBox(height: 32),

            // 2. Thông tin cơ bản
            _buildInput("Tên sách", _titleController),
            const SizedBox(height: 16),
            _buildInput("Tác giả", _authorController),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildInput("Số trang", _pagesController, isNumber: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput("Thể loại", _descController)),
            ]),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // 3. Ô NHẬP NỘI DUNG SÁCH (MỚI)
            Align(alignment: Alignment.centerLeft, child: Text("Nội dung sách (Paste vào đây để đọc)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark))),
            const SizedBox(height: 8),
            Container(
              height: 200, // Cao hơn để dễ nhập nhiều chữ
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: TextField(
                controller: _contentController,
                maxLines: null, // Cho phép xuống dòng thoải mái
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: "Sao chép và dán nội dung chương truyện hoặc sách vào đây...",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: _isLoading ? null : _handleSaveBook,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Lưu lại", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
          child: TextField(controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, decoration: const InputDecoration(border: InputBorder.none)),
        ),
      ],
    );
  }
}