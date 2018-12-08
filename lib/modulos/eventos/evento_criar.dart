import 'package:flutter/material.dart';
import 'package:redesign/widgets/tela_base.dart';

class EventoCriar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: "Novo Evento",
      body: Column(
        children: <Widget>[
          Text("Criar novo evento:"),
          MaterialButton(
            onPressed: () => {},
          )
        ],
      ),
    );
  }


}