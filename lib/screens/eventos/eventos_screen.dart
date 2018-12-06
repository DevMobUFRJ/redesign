import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redesign/screens/widgets/padrao_screen.dart';

class EventosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PadraoScreen(
      title: 'Baby Names',
      body: EventosLista(),
    );
  }
}

class EventosLista extends StatefulWidget {
  @override
  _EventosListaState createState() {
    return _EventosListaState();
  }
}

class _EventosListaState extends State<EventosLista> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('evento').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Evento.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.nome),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.nome),
          trailing: Text(record.local.toString()),
          onTap: () => print(record),
        ),
      ),
    );
  }
}

class Evento {
  final String nome;
  final String local;
  final DocumentReference reference;

  Evento.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['nome'] != null),
        assert(map['local'] != null),
        nome = map['nome'],
        local = map['local'];

  Evento.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Evento<$nome:$local>";
}