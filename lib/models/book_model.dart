// File: lib/models/book_model.dart
import 'package:flutter/material.dart';

class BookModel {
  final String id;
  final String title;       // Tên sách
  final String author;      // Tác giả
  final String? imageUrl;   // Link ảnh bìa (có thể null)
  final Color? coverColor;  // Màu bìa (nếu không có ảnh)
  final int totalPages;     // Tổng số trang
  final int currentPage;    // Trang đang đọc
  final double rating;      // Đánh giá sao

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.imageUrl,
    this.coverColor,
    this.totalPages = 0,
    this.currentPage = 0,
    this.rating = 0.0,
  });

  // Hàm tính phần trăm đọc (Ví dụ: 50%)
  double get progressPercent => totalPages == 0 ? 0 : currentPage / totalPages;
}