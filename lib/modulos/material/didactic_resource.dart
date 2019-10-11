import 'package:cloud_firestore/cloud_firestore.dart';

class DidacticResource {
  static const String collectionName = "material";

  String title;
  String description;
  String url;
  DateTime date;

  /// Pastas de materiais podem conter materiais ou outras pastas dentro.
  bool isFolder;

  DocumentReference reference;

  DidacticResource(
      {this.title,
      this.description,
      this.url,
      this.date,
      this.isFolder,
      this.reference});

  DidacticResource.fromMap(Map<String, dynamic> data, {this.reference})
      : title = data['titulo'] ?? '',
        description = data['descricao'] ?? '',
        url = data['url'] ?? '',
        isFolder = data['eh_pasta'] ?? false,
        date = DateTime.tryParse(data['data']);

  Map<String, dynamic> toJson() => {
        'titulo': title,
        'descricao': description,
        'url': url,
        'eh_pasta': isFolder,
        'data': date.toIso8601String()
      };
}
