import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  static const String collectionName = "forum_post";

  String title;
  String description;
  String createdBy;
  String topicId;
  DateTime date;

  DocumentReference reference;

  ForumPost({this.title, this.description, this.createdBy, this.topicId, this.date, this.reference});

  ForumPost.fromMap(Map<String, dynamic> data, {this.reference}) :
    title = data['titulo'] ?? '',
    description = data['descricao'] ?? '',
    createdBy = data['criadoPor'] ?? '',
    topicId = data['temaId'] ?? '',
    date = data['data'] != null ? DateTime.tryParse(data['data']) : '';

  Map<String, dynamic> toJson() =>
      {
        'titulo': title,
        'descricao': description,
        'criadoPor': createdBy,
        'temaId': topicId,
        'data': date.toIso8601String(),
      };
}