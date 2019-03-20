import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/events/event.dart';
import 'package:redesign/modulos/events/event_display.dart';
import 'package:redesign/modulos/events/event_form.dart';
import 'package:redesign/modulos/user/favorite.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:redesign/widgets/async_data.dart';

class EventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EventsList();
  }
}

class EventsList extends StatefulWidget {
  @override
  _EventsListState createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  bool searching = false;
  TextEditingController _searchController = TextEditingController();
  String search = "";
  List<Favorite> favorites;

  _EventsListState() {
    MyApp.getUserReference()
        .collection(Favorite.collectionName)
        .where('classe', isEqualTo: 'Evento')
        .snapshots()
        .listen((QuerySnapshot query) {
      List<Favorite> newFavorites = [];
      for (DocumentSnapshot d in query.documents) {
        newFavorites.add(new Favorite.fromMap(d.data));
      }
      setState(() {
        favorites = newFavorites;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: 'Eventos',
        body: _buildBody(context),
        fab: MyApp.isStudent()
            ? null
            : FloatingActionButton(
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateEvent(),
                      ),
                    ),
                child: Icon(Icons.add),
                backgroundColor: Style.main.primaryColor,
              ),
        actions: <IconButton>[
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () => toggleSearch(),
          ),
        ]);
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('evento')
          .where("data", isGreaterThan: DateTime.now().toIso8601String())
          .orderBy("data")
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        if (snapshot.data.documents.length == 0)
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Não há eventos futuros cadastrados"),
            ],
          );

        int lastPositionUsed = 0;
        List<DocumentSnapshot> docs = snapshot.data.documents;
        if (favorites != null) {
          for (DocumentSnapshot snapshot in docs) {
            if (favorites
                    .where((f) => f.id == snapshot.reference.documentID)
                    .length >
                0) {
              docs.remove(snapshot);
              // Usado apenas pra mostrar a estrela na lista
              snapshot.data.addAll({'favorito': true});
              docs.insert(lastPositionUsed, snapshot);
              lastPositionUsed +=
                  1; //Faz com que os favoritos continuem na ordem de data
            }
          }
        }
        return _buildList(context, docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(children: [
      Expanded(
        child: ListView(
          children: [
            searching
                ? Container(
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: ShapeDecoration(shape: StadiumBorder()),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          onChanged: searchTextChanged,
                          controller: _searchController,
                          cursorColor: Style.lightGrey,
                          decoration: InputDecoration(
                              hintText: "Buscar",
                              prefixIcon: Icon(Icons.search,
                                  color: Style.primaryColor)),
                        ),
                      ),
                    ]))
                : Container(),
          ]..addAll(
              snapshot.map((data) => _buildListItem(context, data)).toList()),
        ),
      ),
    ]);
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final Event record = Event.fromSnapshot(data);

    if (!record.name.toLowerCase().contains(search) &&
        !record.local.toLowerCase().contains(search) &&
        !record.description.toLowerCase().contains(search)) return Container();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Container(
        key: ValueKey(record.name),
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
                          record.date.day.toString(),
                          style: TextStyle(
                            color: Style.buttonBlue,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          initialsMonth(record.date.month),
                          style: TextStyle(
                            color: Style.buttonBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 70.0,
                    width: 1.0,
                    color: Style.buttonBlue,
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
                                Expanded(
                                  child: Text(
                                    record.name,
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.black54),
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                                data.data['favorito'] != null &&
                                        data.data['favorito']
                                    ? Container(
                                        padding: EdgeInsets.only(top: 10),
                                        child: Icon(Icons.star,
                                            color: Style.primaryColor,
                                            size: 16))
                                    : Container(),
                                Container(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        //alignment: Alignment.bottomRight,
                                        //padding: EdgeInsets.only(right: 10),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Style.buttonBlue,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            NameTextAsync(
                              record.createdBy,
                              TextStyle(
                                color: Colors.black45,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 3),
                child: Divider(
                  color: Colors.black87,
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventForm(event: record),
            ),
          ),
    );
  }

  //Retorna a sigla do mes em portugues
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

  toggleSearch() {
    setState(() {
      searching = !searching;
    });
    if (!searching) {
      _searchController.text = "";
      searchTextChanged("");
    }
  }

  searchTextChanged(String text) {
    setState(() {
      search = text.toLowerCase();
    });
  }
}
