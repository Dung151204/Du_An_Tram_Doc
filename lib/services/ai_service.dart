import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class AIService {
  static const String _apiKey = 'AIzaSyB3VWFSrYmDyW5JNwLJK4aSailF9GWLOIU';

  Future<List<Map<String, dynamic>>> generateFlashcards(BookModel book) async {
    try {
      // 1. Lấy danh sách model hợp lệ
      final listModelsUri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey',
      );

      final modelsResponse = await http.get(listModelsUri);
      if (modelsResponse.statusCode != 200) {
        throw Exception(modelsResponse.body);
      }

      final modelsData = jsonDecode(modelsResponse.body);
      final List models = modelsData['models'];

      final model = models.firstWhere(
            (m) =>
            (m['supportedGenerationMethods'] ?? [])
                .contains('generateContent'),
      )['name'];

      // 2. Gọi generateContent với model hợp lệ
      final generateUri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/$model:generateContent?key=$_apiKey',
      );

      final prompt = '''
Bạn là một chuyên gia giáo dục. Hãy đọc thông tin cuốn sách sau:
Tên sách: "${book.title}"
Tác giả: "${book.author}"
Nội dung: "${book.content}"

Nhiệm vụ: Hãy tự suy nghĩ và tạo ra 5 câu hỏi Flashcard quan trọng nhất để giúp người đọc ghi nhớ kiến thức cốt lõi của cuốn sách này.
Yêu cầu kết quả trả về: Chỉ trả về mã JSON nguyên bản là một danh sách các đối tượng, không kèm lời dẫn, không kèm markdown.
Định dạng: [{"question": "Câu hỏi", "answer": "Đáp án"}]
      ''';

      final response = await http.post(
        generateUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

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
}
