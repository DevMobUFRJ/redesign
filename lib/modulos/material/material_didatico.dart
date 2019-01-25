import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialDidatico {
  static const String collectionName = "material";

  String titulo;
  String descricao;
  String url;
  DateTime data;

  DocumentReference reference;

  MaterialDidatico({this.titulo, this.descricao, this.url, this.data, this.reference});

  MaterialDidatico.fromMap(Map<String, dynamic> data, {this.reference}) :
      titulo = data['titulo'],
      descricao = data['descricao'],
      url = data['url'],
      data = DateTime.tryParse(data['data']);

  Map<String, dynamic> toJson() =>
      {
        'titulo': titulo,
        'descricao': descricao,
        'url': url,
        'data': data.toIso8601String()
      };
}