import 'package:cloud_firestore/cloud_firestore.dart';

class Event {

  static final String collectionName = 'evento';

  DocumentReference reference;
  String name;
  String description;
  DateTime date;
  /// ID do usuário
  String createdBy;
  String facebookUrl;
  String local;
  String address;
  String city;

  Event({this.name, this.description, this.date, this.createdBy,
      this.facebookUrl, this.local, this.address, this.city, this.reference});

  Event.fromMap(Map<String, dynamic> map, {this.reference})
      : name = map['nome'] ?? '',
        description = map['descricao'] ?? '',
        date = map['data'] != null && map['data'] != "" ? DateTime.parse(map['data']) : null,
        createdBy = map['criadoPor'] ?? '',
        facebookUrl = map['facebookUrl'] ?? '',
        local = map['local'] ?? '',
        address = map['endereco'] ?? '',
        city = map['cidade'] ?? '';

  Event.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map<String, dynamic> toJson() =>
      {
        'nome': name ?? '',
        'descricao': description ?? '',
        'data': date != null ? date.toIso8601String() : '',
        'criadoPor': createdBy ?? '',
        'facebookUrl': facebookUrl ?? '',
        'local': local ?? '',
        'endereco': address ?? '',
        'cidade': city ?? ''
      };

  @override
  String toString() => this.toJson().toString();


}