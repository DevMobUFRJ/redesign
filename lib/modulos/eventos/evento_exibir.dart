import 'package:flutter/material.dart';
import 'package:redesign/modulos/eventos/evento.dart';
import 'package:redesign/modulos/eventos/evento_form.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/dados_asincronos.dart';
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
        actions: evento.criadoPor == MeuApp.userId() ? [
          IconButton(
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
          IconButton(
            icon: Icon(
              Icons.delete,
            ),
            onPressed: () => excluirEvento(context),
          ),
        ] : null,
        body: _corpo()
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

  void alternaFavorito(){
    //TODO adicionar ou remover favoritos.
  }

  Widget _corpo() {
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: ListView(
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
                      evento.data.day.toString(),
                      style: TextStyle(
                        color: Tema.buttonBlue,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      initialsMonth(evento.data.month),
                      style: TextStyle(color: Tema.buttonBlue, fontSize: 30),
                    ),
                  ],
                ),
              ),
              Container(
                height: 90.0,
                width: 1.0,
                color: Tema.buttonBlue,
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              ),
              Expanded(
                child: Container(
                  height: 90.0,
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
                            evento.nome,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            maxLines: 2,
                          ),
                          NomeTextAsync(
                            evento.criadoPor,
                            TextStyle(
                              color: Colors.black45,
                              fontSize: 15,
                            ),
                            prefixo: "",
                          ),
                        ],
                      ),

                      Container(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            GestureDetector(
                              child: Container(
                                alignment: Alignment.bottomRight,
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(Icons.collections_bookmark, color: Tema.primaryColor),
                              ),
                              onTap: () => alternaFavorito(),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: Icon(Icons.star_border, color: Tema.primaryColor),
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
          Divider(color: Colors.black45,),
          Container(alignment: Alignment.topLeft,
            padding: EdgeInsets.only(top: 10,bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(dayOfWeekPortuguese(evento.data.weekday) +", " + evento.data.day.toString() +" de "+ monthPortuguese(evento.data.month)+" às " + evento.data.hour.toString(), style: TextStyle(color: Colors.black54),),
                Padding(padding: EdgeInsets.only(bottom: 10)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(child: Icon(Icons.location_on,color: Colors.black45, size: 24,),),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                        Text(evento.local,style: TextStyle(fontSize: 18, color: Colors.black54),),
                        Text(evento.endereco, style: TextStyle(color: Colors.black45)),
                        Text(evento.cidade, style: TextStyle(color: Colors.black45),),
                      ],),
                    )
                  ],
                )

              ],
            ),
          ),Container(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Descrição", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54),),
                ],
              )),
          Divider(color: Colors.black45,),
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

  /// Retorna a nome do mês em portugues
  String monthPortuguese (int numMonth){
    if(numMonth < 1 || numMonth > 12) return "";

    List<String> monthsPortuguese = ["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"];
    return monthsPortuguese[numMonth-1];
  }

  /// Retorna a sigla do mes em portugues
  String initialsMonth (int numMonth){
    if(numMonth < 1 || numMonth > 12) return "";

    List<String> initialsOfMonths = ["JAN","FEV","MAR","ABR","MAI","JUN","JUL","AGO","SET","OUT","NOV","DEZ"];
    return initialsOfMonths[numMonth-1];
  }

  /// Retorna o dia da semana em portugues
  String dayOfWeekPortuguese (int day){
    if(day < 1 || day > 7) return "";

    List<String> dayOfWeek = ["Segunda-feira","Terça-feira","Quarta-feira","Quinta-feira","Sexta-feira","Sábado","Domingo"];
    return dayOfWeek[day-1];
  }
}
