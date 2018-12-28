import 'package:flutter/material.dart';
import 'package:redesign/modulos/eventos/evento.dart';
import 'package:redesign/modulos/eventos/evento_form.dart';
import 'package:redesign/widgets/tela_base.dart';
import 'package:redesign/estilos/tema.dart';

class EventoForm extends StatefulWidget {
  final Evento evento;

  EventoForm({Key key, @required this.evento}) : super(key: key);

  @override
  _EventoExibir createState() => _EventoExibir(evento: this.evento);
}

class _EventoExibir extends State<EventoForm> {
  final Evento evento;

  _EventoExibir({this.evento});

  @override
  Widget build(BuildContext context) {
    return TelaBase(
        title: evento.nome,
        extraActions: [
          IconButton(
            //TODO Mostrar apenas se for do próprio usuário
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventoCriar(evento: this.evento),
                  ),
                ),
          ),
          //TODO Visível apenas para quem criou o evento
          IconButton(
            icon: Icon(
              Icons.delete,
            ),
            onPressed: () => excluirEvento(context),
          ),
        ],
        body: Corpo()
// Column(
//          children: <Widget>[
//            Text("Nome: " + evento.nome),
//            Text("Local: " + evento.local),
//            Text("Dados completos: " + evento.toJson().toString()),
//          ],
//        )
        );
  }

  void excluirEvento(context) {
    evento.reference.delete().then(removido).catchError(naoRemovido);
  }

  void removido(dynamic d) {
    Navigator.pop(context);
  }

  void naoRemovido() {
    //TODO Mostrar erro
  }

  Widget Corpo() {
    return Container(

      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      "10",
                      style: TextStyle(
                        color: Tema.buttonBlue,
                        fontSize: 60,
                      ),
                    ),
                    Text(
                      "OUT",
                      style: TextStyle(color: Tema.buttonBlue, fontSize: 30),
                    ),
                  ],
                ),
              ),
              Container(
                height: 100.0,
                width: 1.0,
                color: Tema.buttonBlue,
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              ),
              Expanded(
                child: Container(
                  height: 100.0,
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            evento.local,
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            evento.criadoPor,
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),

                      Container(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.bottomRight,
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.collections_bookmark),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: Icon(Icons.star_border),
                            ),
                          ],
                        ),
                    )
                  ],
                ),
              )
            ),
            ],
          ),
          MyDivider(),
          Container(alignment: Alignment.topLeft,
            padding: EdgeInsets.only(top: 10,bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Terça-feira, 10 de Outubro às 10:00"),
                Padding(padding: EdgeInsets.only(bottom: 10)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(child: Icon(Icons.location_on,color: Colors.black45,),),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                        Text(evento.local,style: TextStyle(fontSize: 20),),
                        Text(evento.endereco+" - "+ evento.cidade),
                      ],),
                    )
                  ],
                )

              ],
            ),
          ),Container(
              padding: EdgeInsets.only(top: 20, bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Descrição"),
                ],
              )),

          MyDivider(),
          Container(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(evento.descricao, style: TextStyle(color: Colors.black45),),
                ],
              ))
        ],
      ),
    );
  }

  Widget MyDivider(){
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      height: 1.0,
      width: 400.0,
      color: Colors.black45,
    );
  }
}
