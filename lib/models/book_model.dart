import 'package:flutter/material.dart';

class BookModel {
  String? id;               // ID của document trên Firebase (Để null khi mới tạo)
  final String title;       // Tên sách
  final String author;      // Tác giả
  final String? imageUrl;   // Link ảnh bìa
  final int? colorValue;    // Lưu màu dưới dạng số nguyên (Vì Firebase không lưu được Color)
  final int totalPages;     // Tổng số trang
  final int currentPage;    // Trang đang đọc
  final double rating;      // Đánh giá

  BookModel({
    this.id,
    required this.title,
    required this.author,
    this.imageUrl,
    this.colorValue,
    this.totalPages = 0,
    this.currentPage = 0,
    this.rating = 0.0,
  });

  // Getter để lấy ra Color từ số nguyên (Dùng cho UI)
  Color? get coverColor => colorValue != null ? Color(colorValue!) : null;

  // Getter tính phần trăm đọc
  double get progressPercent => totalPages == 0 ? 0 : currentPage / totalPages;

  // 1. Hàm chuyển đổi từ BookModel sang Map (Để GỬI lên Firebase)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'colorValue': colorValue, // Lưu mã màu
      'totalPages': totalPages,
      'currentPage': currentPage,
      'rating': rating,
      'createdAt': DateTime.now().millisecondsSinceEpoch, // Lưu thời gian tạo
    };
  }

  // 2. Hàm chuyển đổi từ Map (Firebase trả về) sang BookModel (Để HIỂN THỊ)
  factory BookModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookModel(
      id: documentId, // Gán ID từ Firebase vào đây
      title: map['title'] ?? 'Không tên',
      author: map['author'] ?? 'Không rõ',
      imageUrl: map['imageUrl'],
      colorValue: map['colorValue'],
      totalPages: map['totalPages']?.toInt() ?? 0,
      currentPage: map['currentPage']?.toInt() ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }
}