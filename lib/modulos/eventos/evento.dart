import 'package:cloud_firestore/cloud_firestore.dart';

class Evento {

  final String nome;
  final String local;
  final int count;
  final DocumentReference reference;

  Evento.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['nome'] != null),
        assert(map['local'] != null),
        nome = map['nome'],
        local = map['local'],
        count = map['count'] ?? 0;

  Evento.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Evento<$nome:$local>";

}