import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import 'book_add_preview_screen.dart';

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
  final _contentController = TextEditingController();

  File? _selectedImage;
  late int _randomColor;
  double _initialRating = 4.5;

  // [MỚI] Biến để chọn công khai hay riêng tư
  bool _isPublic = false;

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

  void _handleNextStep() {
    if (_titleController.text.trim().isEmpty || _authorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thiếu tên sách hoặc tác giả!'), backgroundColor: Colors.orange));
      return;
    }

    String bookId = DateTime.now().millisecondsSinceEpoch.toString();
    String imagePath = _selectedImage != null ? _selectedImage!.path : "";

    // Tạo BookModel với cờ isPublic
    final tempBook = BookModel(
      id: bookId,
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      description: _descController.text.trim(),
      content: _contentController.text,
      totalPages: int.tryParse(_pagesController.text) ?? 0,
      imageUrl: imagePath,
      colorValue: _randomColor,
      createdAt: DateTime.now(),
      rating: _initialRating,
      reviewsCount: 1,
      // [QUAN TRỌNG] Gán giá trị công khai/riêng tư tại đây
      // Lưu ý: Nếu BookModel của bạn chưa có field này,
      // hãy chắc chắn DatabaseService.addBook xử lý nó thông qua Map
      isPublic: _isPublic,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookAddPreviewScreen(
          book: tempBook,
          imageFile: _selectedImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("Nhập sách mới", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 140, height: 190,
                decoration: BoxDecoration(
                  color: _selectedImage == null ? Color(_randomColor) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: _selectedImage != null ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) : null,
                ),
                child: _selectedImage == null ? const Center(child: Icon(Icons.add_photo_alternate, color: Colors.white, size: 32)) : null,
              ),
            ),
            const SizedBox(height: 32),

            _buildInput("Tên sách", _titleController),
            const SizedBox(height: 16),
            _buildInput("Tác giả", _authorController),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildInput("Số trang", _pagesController, isNumber: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput("Thể loại", _descController)),
            ]),

            const SizedBox(height: 16),

            // --- UI ĐÁNH GIÁ ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Đánh giá ban đầu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    Row(children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(" $_initialRating", style: const TextStyle(fontWeight: FontWeight.bold))
                    ]),
                  ],
                ),
                Slider(
                  value: _initialRating,
                  min: 1.0, max: 5.0, divisions: 8,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _initialRating = val),
                )
              ],
            ),

            const SizedBox(height: 16),

            // --- [MỚI] NÚT GẠT CHIA SẺ CỘNG ĐỒNG ---
            // Thiết kế theo style của _buildInput
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Chia sẻ cho cộng đồng?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: const Text("Người khác có thể tìm thấy sách này", style: TextStyle(fontSize: 12, color: Colors.grey)),
                value: _isPublic,
                activeColor: Colors.orange,
                onChanged: (val) => setState(() => _isPublic = val),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            Align(alignment: Alignment.centerLeft, child: Text("Nội dung sách", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark))),
            const SizedBox(height: 8),
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(hintText: "Paste nội dung vào đây...", border: InputBorder.none),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: _handleNextStep,
                child: const Text("Tiếp theo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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