import 'package:cloud_firestore/cloud_firestore.dart';

class ForumComentario {
  static const String collectionName = "comentario";

  String titulo;
  String descricao;
  DateTime data;
  String criadoPor;

  DocumentReference reference;

  ForumComentario({this.titulo, this.descricao, this.data,
    this.criadoPor, this.reference});

  ForumComentario.fromMap(Map<String, dynamic> data, {this.reference}) :
    titulo = data['titulo'],
    descricao = data['descricao'],
    data = data['data'] != null ? DateTime.tryParse(data['data']) : '',
    criadoPor = data['criadoPor'];

  Map<String, dynamic> toJson() =>
      {
        'titulo': titulo,
        'descricao': descricao,
        'data': data.toIso8601String(),
        'criadoPor': criadoPor
      };

}