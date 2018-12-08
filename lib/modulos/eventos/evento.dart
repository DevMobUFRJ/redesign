import 'package:cloud_firestore/cloud_firestore.dart';

class Evento {

  final DocumentReference reference;
  final String nome;
  final String descricao;
  final DateTime data;
  final String criadoPor;
  final String facebookUrl;
  final String local;
  final String endereco;
  final String cidade;
  final String cep;

  Evento(this.nome, this.descricao, this.data, this.criadoPor,
      this.facebookUrl, this.local, this.endereco, this.cidade,
      this.cep, {this.reference});

  Evento.fromMap(Map<String, dynamic> map, {this.reference})
      : nome = map['nome'] ?? '',
        descricao = map['descricao'] ?? '',
        data = map['data'] != null && map['data'] != "" ? DateTime.parse(map['data']) : null,
        criadoPor = map['criadoPor'] ?? '',
        facebookUrl = map['facebookUrl'] ?? '',
        local = map['local'] ?? '',
        endereco = map['endereco'] ?? '',
        cidade = map['cidade'] ?? '',
        cep = map['cep'] ?? '';

  Evento.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Map<String, dynamic> toJson() =>
      {
        'nome': nome ?? '',
        'descricao': descricao ?? '',
        'data': data != null ? data.toIso8601String() : '',
        'criadoPor': criadoPor ?? '',
        'facebookUrl': facebookUrl ?? '',
        'local': local ?? '',
        'endereco': endereco ?? '',
        'cidade': cidade ?? '',
        'cep': cep
      };

  @override
  String toString() => "Evento<$nome:$local>";

}