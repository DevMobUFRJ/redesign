import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/events/event.dart';
import 'package:redesign/modulos/events/event_form.dart';
import 'package:redesign/modulos/user/favorite.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/styles/fb_icon_icons.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/widgets/async_data.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class EventForm extends StatefulWidget {
  final Event event;

  EventForm({Key key, @required this.event}) : super(key: key);

  @override
  _DisplayEvent createState() => _DisplayEvent(event: this.event);
}

class _DisplayEvent extends State<EventForm> {
  final Event event;
  bool isFavorite = false;

  _DisplayEvent({this.event}) {
    MyApp.getUserReference()
        .collection(Favorite.collectionName)
        .where("id", isEqualTo: event.reference.documentID)
        .snapshots()
        .first
        .then((QuerySnapshot favorite) {
      if (favorite.documents.length != 0) {
        setState(() {
          isFavorite = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: event.name,
        actions: event.createdBy == MyApp.userId()
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateEvent(event: this.event),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                  ),
                  onPressed: () => deleteEvent(context),
                ),
              ]
            : null,
        body: _body());
  }

  void deleteEvent(context) {
    event.reference.delete().then(removed).catchError((e) {});
  }

  void removed(dynamic d) {
    Navigator.pop(context);
  }

  bool isBeingUsed = false;
  void toggleFavorite() {
    if (isBeingUsed) return;
    isBeingUsed = true;
    MyApp.getUserReference()
        .collection(Favorite.collectionName)
        .where("id", isEqualTo: event.reference.documentID)
        .snapshots()
        .first
        .then((QuerySnapshot vazio) {
      if (vazio.documents.length == 0) {
        MyApp.getUserReference()
            .collection(Favorite.collectionName)
            .add((new Favorite(
                    id: event.reference.documentID,
                    className: event.runtimeType.toString())
                .toJson()))
            .then((v) {
          setState(() {
            isFavorite = true;
          });
          isBeingUsed = false;
        }).catchError((e) {});
      } else {
        vazio.documents.first.reference.delete().then((v) {
          setState(() {
            isFavorite = false;
          });
          isBeingUsed = false;
        }).catchError((e) {});
      }
    }).catchError((e) {});
  }

  Widget _body() {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      child: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      event.date.day.toString(),
                      style: const TextStyle(
                        color: Style.buttonBlue,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      initialsMonth(event.date.month),
                      style: const TextStyle(
                          color: Style.buttonBlue, fontSize: 30),
                    ),
                  ],
                ),
              ),
              Container(
                height: 90.0,
                width: 1.0,
                color: Style.buttonBlue,
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
                          event.name,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          maxLines: 2,
                        ),
                        NameTextAsync(
                          event.createdBy,
                          const TextStyle(
                            color: Colors.black45,
                            fontSize: 15,
                          ),
                          prefix: "",
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          event.facebookUrl.isEmpty
                              ? Container()
                              : GestureDetector(
                                  child: Container(
                                    alignment: Alignment.bottomRight,
                                    padding: const EdgeInsets.only(right: 10),
                                    child: const Icon(
                                      FbIcon.facebook_official,
                                      color: Style.primaryColor,
                                      size: 28,
                                    ),
                                  ),
                                  onTap: () => _launchURL(event.facebookUrl),
                                ),
                          GestureDetector(
                            child: Container(
                              alignment: Alignment.bottomRight,
                              child: isFavorite
                                  ? const Icon(
                                      Icons.star,
                                      color: Style.primaryColor,
                                      size: 28,
                                    )
                                  : const Icon(
                                      Icons.star_border,
                                      color: Style.primaryColor,
                                      size: 28,
                                    ),
                            ),
                            onTap: () => toggleFavorite(),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )),
            ],
          ),
          const Divider(
            color: Colors.black45,
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(top: 10, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  dayOfWeekPortuguese(event.date.weekday) +
                      ", " +
                      event.date.day.toString() +
                      " de " +
                      monthPortuguese(event.date.month) +
                      " de " +
                      event.date.year.toString() +
                      " às " +
                      (event.date.hour < 10 ? "0" : "") +
                      event.date.hour.toString() +
                      ":" +
                      (event.date.minute < 10 ? "0" : "") +
                      event.date.minute.toString(),
                  style: const TextStyle(color: Colors.black54),
                ),
                Padding(padding: const EdgeInsets.only(bottom: 10)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.black45,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            event.local,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black54),
                          ),
                          Text(event.address,
                              style: const TextStyle(color: Colors.black45)),
                          Text(
                            event.city,
                            style: const TextStyle(color: Colors.black45),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Container(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Descrição",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              )),
          const Divider(
            color: Colors.black45,
          ),
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  child: Text(
                    event.description,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Retorna a nome do mês em portugues
  String monthPortuguese(int numMonth) {
    if (numMonth < 1 || numMonth > 12) return "";

    List<String> monthsPortuguese = [
      "Janeiro",
      "Fevereiro",
      "Março",
      "Abril",
      "Maio",
      "Junho",
      "Julho",
      "Agosto",
      "Setembro",
      "Outubro",
      "Novembro",
      "Dezembro"
    ];
    return monthsPortuguese[numMonth - 1];
  }

  /// Retorna a sigla do mes em portugues
  String initialsMonth(int numMonth) {
    if (numMonth < 1 || numMonth > 12) return "";

    List<String> initialsOfMonths = [
      "JAN",
      "FEV",
      "MAR",
      "ABR",
      "MAI",
      "JUN",
      "JUL",
      "AGO",
      "SET",
      "OUT",
      "NOV",
      "DEZ"
    ];
    return initialsOfMonths[numMonth - 1];
  }

  /// Retorna o dia da semana em portugues
  String dayOfWeekPortuguese(int day) {
    if (day < 1 || day > 7) return "";

    List<String> dayOfWeek = [
      "Segunda-feira",
      "Terça-feira",
      "Quarta-feira",
      "Quinta-feira",
      "Sexta-feira",
      "Sábado",
      "Domingo"
    ];
    return dayOfWeek[day - 1];
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
