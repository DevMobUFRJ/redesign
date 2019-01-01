import 'package:cloud_firestore/cloud_firestore.dart';

class Mensagem {
  static const String collectionName = "mensagens";

  String descricao;
  DateTime data;
  bool lida;
  /// ID do usuário que enviou a mensagem
  String criadaPor;
  DocumentReference reference;

  Mensagem({this.descricao, this.data, this.lida = false, this.criadaPor});

  Mensagem.fromMap(Map<String, dynamic> map, {this.reference}) :
    descricao = map['descricao'],
    data = map['data'] != null ? DateTime.tryParse(map['data']) : '',
    lida = map['lida'],
    criadaPor = map['criadaPor'];

  Map<String, dynamic> toJson() =>
      {
        'descricao': descricao,
        'data': data.toIso8601String(),
        'lida': lida,
        'criadaPor': criadaPor
      };
}