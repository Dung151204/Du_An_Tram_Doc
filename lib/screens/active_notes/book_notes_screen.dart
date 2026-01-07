import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'; // OCR
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/book_model.dart';
import '../../models/note_model.dart';

class BookNotesScreen extends StatefulWidget {
  final BookModel book;
  const BookNotesScreen({super.key, required this.book});

  @override
  State<BookNotesScreen> createState() => _BookNotesScreenState();
}

class _BookNotesScreenState extends State<BookNotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          tabs: const [
            Tab(text: "Ghi chú trang"),   // FR2.1 & FR2.2
            Tab(text: "Ý tưởng cốt lõi"), // FR2.3
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPageNotesTab(),
          _buildKeyTakeawaysTab(),
        ],
      ),
      // Nút thêm ghi chú (chỉ hiện ở Tab 1)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddNoteDialog(context);
          } else {
            // Logic thêm Key Takeaway
            _showAddTakeawayDialog(context);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // --- TAB 1: DANH SÁCH GHI CHÚ (FR2.1) ---
  Widget _buildPageNotesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('books')
          .doc(widget.book.id)
          .collection('notes')
          .orderBy('pageNumber')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("Chưa có ghi chú nào.\nBấm + để thêm.", textAlign: TextAlign.center));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final note = NoteModel.fromMap(docs[index].data() as Map<String, dynamic>, docs[index].id);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Text("${note.pageNumber}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                title: Text(note.content),
                subtitle: Text("Đã lưu lúc: ${_formatDate(note.createdAt)}"),
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 2: Ý TƯỞNG CỐT LÕI (FR2.3) ---
  Widget _buildKeyTakeawaysTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('books').doc(widget.book.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final bookData = BookModel.fromMap(snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);
        final takeaways = bookData.keyTakeaways;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "3-5 Bài học rút ra từ sách:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            ...takeaways.asMap().entries.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("#${entry.key + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 15))),
                ],
              ),
            )),
            if (takeaways.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: Text("Chưa có tổng kết nào.\nHãy đúc kết lại cuốn sách này!")),
              )
          ],
        );
      },
    );
  }

  // --- HÀM XỬ LÝ: THÊM GHI CHÚ & OCR (FR2.2) ---
  void _showAddNoteDialog(BuildContext context) {
    final pageController = TextEditingController(text: widget.book.currentPage.toString()); // Mặc định là trang hiện tại
    final contentController = TextEditingController();

    // Hàm gọi Camera & OCR
    Future<void> _scanText() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        // FR2.2: Xử lý OCR
        final inputImage = InputImage.fromFilePath(image.path);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

        // Điền text nhận diện được vào ô nhập
        contentController.text = recognizedText.text;
        textRecognizer.close();
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ghi chú mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Trang số", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Nội dung", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            // Nút Quét OCR
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(ctx); // Đóng dialog tạm thời để mở cam
                await _scanText();
                // Mở lại dialog với text đã điền (để đơn giản hóa, ở đây tôi giả lập luồng.
                // Thực tế nên dùng StatefulWidget cho Dialog hoặc setState)
                if (context.mounted) _showAddNoteDialogWithData(context, pageController.text, contentController.text);
              },
              icon: const Icon(LucideIcons.scanLine, color: Colors.blue),
              label: const Text("Quét ảnh sang chữ (OCR)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              // Lưu vào Firebase
              FirebaseFirestore.instance.collection('books').doc(widget.book.id).collection('notes').add({
                'pageNumber': int.tryParse(pageController.text) ?? 0,
                'content': contentController.text,
                'createdAt': DateTime.now().millisecondsSinceEpoch,
              });
              Navigator.pop(ctx);
            },
            child: const Text("Lưu"),
          )
        ],
      ),
    );
  }

  // Dialog phụ để hiện lại dữ liệu sau khi scan xong (vì dialog cũ bị đóng)
  void _showAddNoteDialogWithData(BuildContext context, String page, String content) {
    final pageController = TextEditingController(text: page);
    final contentController = TextEditingController(text: content);
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Kết quả Quét"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: pageController, decoration: const InputDecoration(labelText: "Trang số")),
              const SizedBox(height: 12),
              TextField(controller: contentController, maxLines: 5, decoration: const InputDecoration(labelText: "Nội dung (Có thể sửa)")),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('books').doc(widget.book.id).collection('notes').add({
                  'pageNumber': int.tryParse(pageController.text) ?? 0,
                  'content': contentController.text,
                  'createdAt': DateTime.now().millisecondsSinceEpoch,
                });
                Navigator.pop(ctx);
              },
              child: const Text("Lưu Note"),
            )
          ],
        )
    );
  }

  // Dialog thêm Key Takeaway
  void _showAddTakeawayDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Thêm bài học cốt lõi"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Ví dụ: Nên đọc sách mỗi ngày...", border: OutlineInputBorder()),
        ),
        actions: [
          ElevatedButton(onPressed: () {
            // Dùng FieldValue.arrayUnion để thêm vào mảng có sẵn
            FirebaseFirestore.instance.collection('books').doc(widget.book.id).update({
              'keyTakeaways': FieldValue.arrayUnion([controller.text])
            });
            Navigator.pop(ctx);
          }, child: const Text("Thêm"))
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) => "${dt.day}/${dt.month} ${dt.hour}:${dt.minute}";
}