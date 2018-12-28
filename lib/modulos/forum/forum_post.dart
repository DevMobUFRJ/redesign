import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  static const String collectionName = "forum_post";

  String titulo;
  String descricao;
  String criadoPor;
  String temaId;
  DateTime data;

  DocumentReference reference;

  ForumPost({this.titulo, this.descricao, this.criadoPor, this.temaId, this.data, this.reference});

  ForumPost.fromMap(Map<String, dynamic> data, {this.reference}) :
    titulo = data['titulo'] ?? '',
    descricao = data['descricao'] ?? '',
    criadoPor = data['criadoPor'] ?? '',
    temaId = data['temaId'] ?? '',
    data = data['data'] != null ? DateTime.tryParse(data['data']) : '';

  Map<String, dynamic> toJson() =>
      {
        'titulo': titulo,
        'descricao': descricao,
        'criadoPor': criadoPor,
        'temaId': temaId,
        'data': data.toIso8601String(),
      };
}