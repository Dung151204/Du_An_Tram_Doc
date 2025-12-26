import 'package:flutter/material.dart';

class BookModel {
  String? id;
  final String title;
  final String author;
  final String description;
  final String content;     // <--- 1. MỚI THÊM: Biến lưu nội dung sách
  final String imageUrl;
  final int? colorValue;
  final int totalPages;
  final int currentPage;
  final double rating;
  final int reviewsCount;
  final DateTime createdAt;

  BookModel({
    this.id,
    required this.title,
    required this.author,
    this.description = "",
    this.content = "",      // <--- 2. Mặc định là rỗng
    required this.imageUrl,
    this.colorValue,
    this.totalPages = 0,
    this.currentPage = 0,
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.createdAt,
  });

  Color? get coverColor => colorValue != null ? Color(colorValue!) : null;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'content': content,   // <--- 3. Gửi nội dung lên Firebase
      'imageUrl': imageUrl,
      'colorValue': colorValue,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookModel(
      id: documentId,
      title: map['title'] ?? 'Không tên',
      author: map['author'] ?? 'Không rõ',
      description: map['description'] ?? '',
      content: map['content'] ?? '', // <--- 4. Lấy nội dung về (nếu không có thì trả về rỗng)
      imageUrl: map['imageUrl'] ?? '',
      colorValue: map['colorValue'],
      totalPages: map['totalPages']?.toInt() ?? 0,
      currentPage: map['currentPage']?.toInt() ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewsCount: map['reviewsCount']?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }
}