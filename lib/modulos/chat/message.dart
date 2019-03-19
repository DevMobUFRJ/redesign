import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  static const String collectionName = "mensagens";

  String description;
  DateTime date;
  bool read;
  /// ID do usuário que enviou a mensagem
  String createdBy;
  DocumentReference reference;

  Message({this.description, this.date, this.read = false, this.createdBy});

  Message.fromMap(Map<String, dynamic> map, {this.reference}) :
    description = map['descricao'],
    date = map['data'] != null ? DateTime.tryParse(map['data']) : '',
    read = map['lida'],
    createdBy = map['criadaPor'];

  Map<String, dynamic> toJson() =>
      {
        'descricao': description,
        'data': date.toIso8601String(),
        'lida': read,
        'criadaPor': createdBy
      };

  String timestamp(){
    return date.hour.toString() + ":" + ((date.minute < 10) ? "0" : "") + date.minute.toString();
  }

}
