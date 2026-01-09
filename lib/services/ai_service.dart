import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class AIService {
  // ✅ Đã cập nhật Key mới của bạn
  static const String _apiKey = 'AIzaSyDAPKQ3GyyHPAvVxY3Ps0nUK_cFqPVcmH0';  //Lên https://aistudio.google.com/u/1/api-keys để lấy key

  // Hàm private để tái sử dụng logic gọi API, tránh trùng lặp code
  Future<List<Map<String, dynamic>>> _callGeminiAPI({
    required String promptText,
  }) async {
    try {
      // 1. Lấy model
      final listModelsUri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey',
      );
      final modelsResponse = await http.get(listModelsUri);
      if (modelsResponse.statusCode != 200) throw Exception(modelsResponse.body);

      final modelsData = jsonDecode(modelsResponse.body);
      final List models = modelsData['models'];
      final model = models.firstWhere(
            (m) => (m['supportedGenerationMethods'] ?? []).contains('generateContent'),
      )['name'];

      // 2. Gọi generateContent
      final generateUri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/$model:generateContent?key=$_apiKey',
      );

      final response = await http.post(
        generateUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{"parts": [{"text": promptText}]}]
        }),
      );

      if (response.statusCode != 200) throw Exception(response.body);

      final data = jsonDecode(response.body);
      String responseText =
          data['candidates'][0]['content']['parts'][0]['text'] ?? '[]';

      if (responseText.contains('```')) {
        responseText = responseText.split('```')[1];
        if (responseText.startsWith('json')) {
          responseText = responseText.substring(4);
        }
      }
      responseText = responseText.trim();
      final List<dynamic> decoded = jsonDecode(responseText);
      return List<Map<String, dynamic>>.from(decoded);
    } catch (e) {
      print("❌ Lỗi AI Service: $e");
      return [];
    }
  }

  // 1. Tạo Flashcard cho toàn bộ sách
  Future<List<Map<String, dynamic>>> generateFlashcards(BookModel book) async {
    final prompt = '''
Bạn là một chuyên gia giáo dục. Hãy đọc thông tin cuốn sách sau:
Tên sách: "${book.title}"
Tác giả: "${book.author}"
Nội dung: "${book.content}"

Nhiệm vụ: Hãy tự suy nghĩ và tạo ra 5 câu hỏi Flashcard quan trọng nhất để giúp người đọc ghi nhớ kiến thức cốt lõi của cuốn sách này.
Yêu cầu kết quả trả về: Chỉ trả về mã JSON nguyên bản là một danh sách các đối tượng, không kèm lời dẫn, không kèm markdown.
Định dạng: [{"question": "Câu hỏi", "answer": "Đáp án"}]
      ''';
    return _callGeminiAPI(promptText: prompt);
  }

  // 2. Tạo Flashcard THEO TIẾN ĐỘ (Cắt text theo trang)
  Future<List<Map<String, dynamic>>> generateQuizFromProgress(BookModel book, int currentPage) async {
    String textForAI = book.content;

    // Nếu sách là dạng Text (không có PDF Asset) -> Cần cắt nội dung theo trang
    if ((book.assetPath == null || book.assetPath!.isEmpty) && book.content.isNotEmpty) {
      const int charsPerPage = 1500; // Quy ước giống bên DatabaseService

      // Tính vị trí cắt: Đọc đến trang nào thì cắt đến đó
      int endCharIndex = currentPage * charsPerPage;

      // Đảm bảo không cắt lố độ dài thật
      if (endCharIndex > book.content.length) {
        endCharIndex = book.content.length;
      }

      // Lấy nội dung từ đầu đến trang hiện tại
      textForAI = book.content.substring(0, endCharIndex);
      print("🤖 AI đang đọc $endCharIndex ký tự (Đến trang $currentPage)...");
    }

    final prompt = '''
Bạn là chuyên gia giáo dục. Người dùng đang đọc cuốn sách "${book.title}".
Dưới đây là nội dung họ ĐÃ ĐỌC ĐƯỢC (từ đầu đến trang $currentPage):
"$textForAI"

Nhiệm vụ: Tạo 2-3 câu hỏi trắc nghiệm (Flashcard) chỉ dựa trên phần nội dung đã đọc này để ôn tập.
Yêu cầu: Trả về JSON list. Không kèm markdown.
Định dạng: [{"question": "Câu hỏi", "answer": "Đáp án đúng"}]
    ''';

    return _callGeminiAPI(promptText: prompt);
  }
}