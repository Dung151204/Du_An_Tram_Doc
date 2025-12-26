class ReviewModel {
  final String id;
  final String bookId;
  final String userId;
  final String userName; // Lưu tên người dùng để hiển thị cho nhanh
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  // Chuyển đổi sang Map để gửi lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Nhận dữ liệu từ Firebase về App
  factory ReviewModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ReviewModel(
      id: documentId,
      bookId: map['bookId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Ẩn danh',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}