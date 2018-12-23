
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:redesign/modulos/eventos/evento.dart';
import 'package:redesign/widgets/tela_base.dart';

class EventoExibir extends StatelessWidget {

  final Evento evento;

  // In the constructor, require a Todo
  EventoExibir({Key key, @required this.evento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: evento.nome,
      body: Column(
        children: <Widget>[
          Text("Nome: " + evento.nome),
          Text("Local: " + evento.local),
          Text("Dados completos: " + evento.toJson().toString())
        ],
      ),
    );
  }
}