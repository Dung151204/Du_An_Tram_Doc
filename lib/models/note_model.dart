import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  String id;
  String content;
  int pageNumber;
  DateTime createdAt;

  NoteModel({
    required this.id,
    required this.content,
    required this.pageNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'pageNumber': pageNumber,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map, String id) {
    return NoteModel(
      id: id,
      content: map['content'] ?? '',
      pageNumber: map['pageNumber'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}