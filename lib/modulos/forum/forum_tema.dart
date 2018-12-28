import 'package:cloud_firestore/cloud_firestore.dart';

class ForumTema {
  static const String collectionName = "forum_tema";

  String titulo;
  DocumentReference reference;

  ForumTema({this.titulo, this.reference});

  ForumTema.fromMap(Map<String, dynamic> data, {this.reference}) :
        titulo = data['titulo'] ?? '';

  Map<String, dynamic> toJson() =>
      {
        'titulo': titulo ?? '',
      };
}