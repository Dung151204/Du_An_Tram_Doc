import 'package:cloud_firestore/cloud_firestore.dart';
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

  final String? userId;
  final bool isPublic;
  final String readingStatus;
  final String physicalLocation;
  final String lentTo;
  final DateTime? returnDate; // [QUAN TRỌNG] Thêm trường này để lưu ngày trả
  final String? assetPath;
  final List<String> keyTakeaways;

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
    this.userId,
    this.isPublic = false,
    this.readingStatus = 'reading',
    this.physicalLocation = '',
    this.lentTo = '',
    this.returnDate, // Thêm vào constructor
    this.assetPath,
    this.keyTakeaways = const [],
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
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'isPublic': isPublic,
      'readingStatus': readingStatus,
      'physicalLocation': physicalLocation,
      'lentTo': lentTo,
      // Lưu ngày trả dưới dạng Timestamp nếu có
      'returnDate': returnDate != null ? Timestamp.fromDate(returnDate!) : null,
      'assetPath': assetPath,
      'keyTakeaways': keyTakeaways,
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Hàm xử lý ngày tháng an toàn
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }

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
      rating: (map['rating'] is int) ? (map['rating'] as int).toDouble() : (map['rating'] ?? 0.0).toDouble(),
      reviewsCount: map['reviewsCount']?.toInt() ?? 0,

      createdAt: parseDate(map['createdAt']),

      userId: map['userId'],
      isPublic: map['isPublic'] ?? false,
      readingStatus: map['readingStatus'] ?? 'reading',
      physicalLocation: map['physicalLocation'] ?? '',
      lentTo: map['lentTo'] ?? '',

      // Xử lý ngày trả khi đọc về
      returnDate: map['returnDate'] != null ? parseDate(map['returnDate']) : null,

      assetPath: map['assetPath'],
      keyTakeaways: List<String>.from(map['keyTakeaways'] ?? []),
    );
  }
}