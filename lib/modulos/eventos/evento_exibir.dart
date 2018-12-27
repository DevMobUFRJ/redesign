
import 'package:flutter/material.dart';
import 'package:redesign/modulos/eventos/evento.dart';
import 'package:redesign/modulos/eventos/evento_form.dart';
import 'package:redesign/widgets/tela_base.dart';

class EventoForm extends StatefulWidget {

  final Evento evento;

  EventoForm({Key key, @required this.evento}) : super(key: key);

  @override
  _EventoExibir createState() => _EventoExibir(evento: this.evento);
}

class _EventoExibir extends State<EventoForm>{

  final Evento evento;

  _EventoExibir({this.evento});

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: evento.nome,
      body: Column(
        children: <Widget>[
          Text("Nome: " + evento.nome),
          Text("Local: " + evento.local),
          Text("Dados completos: " + evento.toJson().toString()),
        ],
      ),
      extraActions: [
        IconButton( //TODO Mostrar apenas se for do próprio usuário
          icon: Icon(
            Icons.edit,
            color: Colors.white,
          ),
          onPressed: () =>
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventoCriar(evento: this.evento),
              ),
            ),
        ),
        //TODO Visível apenas para quem criou o evento
        IconButton(icon: Icon(
          Icons.delete,
        ),
          onPressed: () => excluirEvento(context),
        ),
      ]
    );
  }

  void excluirEvento(context){
    evento.reference.delete().then(removido).catchError(naoRemovido);
  }

  void removido(dynamic d){
    Navigator.pop(context);
  }

  void naoRemovido(){
    //TODO Mostrar erro
  }
}