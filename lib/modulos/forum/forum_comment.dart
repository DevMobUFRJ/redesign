import 'package:cloud_firestore/cloud_firestore.dart';

class ForumComment {
  static const String collectionName = "comentario";

  String title;
  String description;
  DateTime date;
  String createdBy;

  DocumentReference reference;

  ForumComment({this.title, this.description, this.date,
    this.createdBy, this.reference});

  ForumComment.fromMap(Map<String, dynamic> data, {this.reference}) :
    title = data['titulo'],
    description = data['descricao'],
    date = data['data'] != null ? DateTime.tryParse(data['data']) : '',
    createdBy = data['criadoPor'];

  Map<String, dynamic> toJson() =>
      {
        'titulo': title,
        'descricao': description,
        'data': date.toIso8601String(),
        'criadoPor': createdBy
      };

}