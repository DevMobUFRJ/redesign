import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/eventos/evento.dart';
import 'package:redesign/modulos/eventos/evento_exibir.dart';
import 'package:redesign/modulos/eventos/evento_form.dart';
import 'package:redesign/modulos/eventos/evento_exibir.dart';
import 'package:redesign/widgets/tela_base.dart';

class EventosTela extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: 'Eventos',
      body: EventosLista(),
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
        actions: <IconButton>[ IconButton(
        icon: Icon(
            Icons.search,
            color: Colors.white
        ),
        onPressed: () => {},
      ),
    ]
    );
  }
}

class EventosLista extends StatefulWidget {

  @override
  _EventosListaState createState() => _EventosListaState();
}

class _EventosListaState extends State<EventosLista> {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('evento')
          .where("data", isGreaterThan: DateTime.now().toIso8601String())
          .orderBy("data")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(
      children: [
        Expanded(
          child:  ListView(
            children: snapshot.map((data) => _buildListItem(context, data)).toList(),

          ),
        ),
      ]
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Evento.fromSnapshot(data);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Container(
        key: ValueKey(record.nome),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6.0),
        child: Container(
          height: 89,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          record.data.day.toString(),
                          style: TextStyle(
                            color: Tema.buttonBlue,
                            fontSize: 40,
                          ),
                        ),
                        Text(
                          initialsMonth(record.data.month),
                          style: TextStyle(color: Tema.buttonBlue, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 70.0,
                    width: 1.0,
                    color: Tema.buttonBlue,
                    margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                  ),
                  Expanded(
                      child: Container(
                        height: 70.0,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      record.local,
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.black54
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 10),
                                      alignment: Alignment.bottomRight,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            //alignment: Alignment.bottomRight,
                                            //padding: EdgeInsets.only(right: 10),
                                            child: Icon(Icons.arrow_forward_ios, color: Tema.buttonBlue,size: 20,),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Text(
                                  "Pessoa",
                                  //record.criadoPor,
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      )
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 3),
                child: Divider(color: Colors.black87,),
              )
            ],
          ),
        ),
      ),
        onTap: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventoForm(evento: record),
                  ),
                ),
    );
  }

  //Retorna a sigla do mes em portugues
  String initialsMonth ( int numMonth){
    List<String> initialsOfMonths = ["JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"];
    for(int i = 0 ; i < initialsOfMonths.length; i++){
      if(numMonth == i+1){
        return initialsOfMonths[i];
      }
    }
  }
}

//child: ListTile(
//            title: Text(record.nome),
//            subtitle: Text(record.local),
//            trailing: Text(">"),
//            onTap: () =>
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                    builder: (context) => EventoForm(evento: record),
//                  ),
//                ),
//          )