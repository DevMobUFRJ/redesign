import 'package:cloud_firestore/cloud_firestore.dart';

class ForumTopic {
  static const String collectionName = "forum_tema";

  String title;
  DocumentReference reference;

  ForumTopic({this.title, this.reference});

  ForumTopic.fromMap(Map<String, dynamic> data, {this.reference}) :
        title = data['titulo'] ?? '';

  Map<String, dynamic> toJson() =>
      {
        'titulo': title ?? '',
      };
}