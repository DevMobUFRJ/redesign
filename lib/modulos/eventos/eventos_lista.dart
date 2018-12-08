import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/eventos/evento.dart';
import 'package:redesign/modulos/eventos/evento_criar.dart';
import 'package:redesign/modulos/eventos/evento_exibir.dart';
import 'package:redesign/widgets/tela_base.dart';

class EventosTela extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: 'Eventos',
      body: Container(
        child: EventosLista()
      ),
      fab: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventoCriar(),
            ),
          ),
        child: Icon(Icons.add),
        backgroundColor: Tema.principal.primaryColor,
      ),
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
          subtitle: Text(record.local),
          trailing: Text(">"),
          onTap: () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventoExibir(evento: record),
                ),
              ),
        ),
      ),
    );
  }
}