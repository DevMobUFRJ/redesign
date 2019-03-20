import 'package:cloud_firestore/cloud_firestore.dart';

class DidacticResource {
  static const String collectionName = "material";

  String title;
  String description;
  String url;
  DateTime date;

  DocumentReference reference;

  DidacticResource(
      {this.title, this.description, this.url, this.date, this.reference});

  DidacticResource.fromMap(Map<String, dynamic> data, {this.reference})
      : title = data['titulo'],
        description = data['descricao'],
        url = data['url'],
        date = DateTime.tryParse(data['data']);

  Map<String, dynamic> toJson() => {
        'titulo': title,
        'descricao': description,
        'url': url,
        'data': date.toIso8601String()
      };
}
