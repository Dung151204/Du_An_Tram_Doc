import 'package:flutter/material.dart';

class BookModel {
  String? id;
  final String title;
  final String author;
  final String description;
  final String content;
  final String imageUrl;
  final int? colorValue;
  final int totalPages;
  final int currentPage;
  final double rating;
  final int reviewsCount;
  final DateTime createdAt;

  // --- CÁC TRƯỜNG MỞ RỘNG (ĐẦY ĐỦ) ---
  final String? userId;
  final bool isPublic;
  final String readingStatus;     // Trạng thái đọc
  final String physicalLocation;  // Vị trí sách giấy
  final String lentTo;            // Cho ai mượn
  final String? assetPath;        // Đường dẫn PDF offline
  final List<String> keyTakeaways; // <--- ĐÃ THÊM LẠI TRƯỜNG NÀY (Để sửa lỗi)
  // -----------------------------------

  BookModel({
    this.id,
    required this.title,
    required this.author,
    this.description = "",
    this.content = "",
    required this.imageUrl,
    this.colorValue,
    this.totalPages = 0,
    this.currentPage = 0,
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.createdAt,

    // Constructor đầy đủ
    this.userId,
    this.isPublic = false,
    this.readingStatus = 'reading',
    this.physicalLocation = '',
    this.lentTo = '',
    this.assetPath,
    this.keyTakeaways = const [], // Mặc định là danh sách rỗng
  });

  Color? get coverColor => colorValue != null ? Color(colorValue!) : null;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'content': content,
      'imageUrl': imageUrl,
      'colorValue': colorValue,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'createdAt': createdAt.millisecondsSinceEpoch,

      // Lưu tất cả lên Firebase
      'userId': userId,
      'isPublic': isPublic,
      'readingStatus': readingStatus,
      'physicalLocation': physicalLocation,
      'lentTo': lentTo,
      'assetPath': assetPath,
      'keyTakeaways': keyTakeaways, // <--- Lưu mảng này
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookModel(
      id: documentId,
      title: map['title'] ?? 'Không tên',
      author: map['author'] ?? 'Không rõ',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      colorValue: map['colorValue'],
      totalPages: map['totalPages']?.toInt() ?? 0,
      currentPage: map['currentPage']?.toInt() ?? 0,
      rating: (map['rating'] is int)
          ? (map['rating'] as int).toDouble()
          : (map['rating'] ?? 0.0).toDouble(),
      reviewsCount: map['reviewsCount']?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),

      // Đọc về
      userId: map['userId'],
      isPublic: map['isPublic'] ?? false,
      readingStatus: map['readingStatus'] ?? 'reading',
      physicalLocation: map['physicalLocation'] ?? '',
      lentTo: map['lentTo'] ?? '',
      assetPath: map['assetPath'],

      // Đọc mảng Key Takeaways an toàn
      keyTakeaways: List<String>.from(map['keyTakeaways'] ?? []),
    );
  }
}