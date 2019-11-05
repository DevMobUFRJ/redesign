import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ForumPost {
  static const String collectionName = "forum_post";

  String title;
  String description;
  String createdBy;
  String topicId;
  DateTime date;
  String filename;

  DocumentReference reference;

  ForumPost(
      {this.title,
      this.description,
      this.createdBy,
      this.topicId,
      this.date,
      this.reference,
      this.filename});

  ForumPost.fromMap(Map<String, dynamic> data, {this.reference})
      : title = data['titulo'] ?? '',
        description = data['descricao'] ?? '',
        createdBy = data['criadoPor'] ?? '',
        topicId = data['temaId'] ?? '',
        filename = data['anexo'],
        date = data['data'] != null ? DateTime.tryParse(data['data']) : '';

  Map<String, dynamic> toJson() => {
        'titulo': title,
        'descricao': description,
        'criadoPor': createdBy,
        'temaId': topicId,
        'anexo': filename,
        'data': date.toIso8601String(),
      };

  updatePost() {
    reference.updateData(this.toJson());
  }

  deletePost() {
    reference.delete();
  }

  Future<DocumentReference> savePost(String path) async {
    File file = path == "nenhum" ? null : File(path);
    if (file != null) {
      String extension = path.split("/").last.split(".").last;
      String name = "${DateTime.now().millisecondsSinceEpoch}.$extension";
      this.filename = name;
      StorageUploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child("files/$name")
          .putData(await file.readAsBytes());
      uploadTask.onComplete
          .then((s) => print("saved: $s"))
          .catchError((e) => print(e));
    }
    return await Firestore.instance
        .collection(collectionName)
        .add(this.toJson());
  }
}
