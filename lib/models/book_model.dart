import 'package:flutter/material.dart';

class BookModel {
  String? id;
  final String title;
  final String author;
  final String description;
  final String content;     // Giữ nguyên của bạn
  final String imageUrl;
  final int? colorValue;
  final int totalPages;
  final int currentPage;
  final double rating;
  final int reviewsCount;
  final DateTime createdAt;

  // --- PHẦN BẮT BUỘC PHẢI THÊM ĐỂ SỬA LỖI ---
  final String? userId; // Để biết sách của ai
  final bool isPublic;  // Để chỉnh chế độ Riêng tư/Công khai
  final String status;  // Để biết đang đọc hay đã xong
  // ------------------------------------------

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

    // --- THÊM VÀO CONSTRUCTOR ---
    this.userId,
    this.isPublic = false, // Mặc định là riêng tư
    this.status = 'reading',
    // ----------------------------
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

      // --- THÊM VÀO ĐỂ LƯU LÊN FIREBASE ---
      'userId': userId,
      'isPublic': isPublic,
      'status': status,
      // ------------------------------------
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
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewsCount: map['reviewsCount']?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),

      // --- THÊM VÀO ĐỂ ĐỌC VỀ KHÔNG BỊ LỖI ---
      userId: map['userId'],
      isPublic: map['isPublic'] ?? false,
      status: map['status'] ?? 'reading',
      // ---------------------------------------
    );
  }
}