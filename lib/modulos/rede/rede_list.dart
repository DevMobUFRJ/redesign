import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/user/favorite.dart';
import 'package:redesign/modulos/user/institution.dart';
import 'package:redesign/modulos/user/profile_institution.dart';
import 'package:redesign/modulos/user/profile_person.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/services/helper.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/simple_list_item.dart';
import 'package:redesign/widgets/base_screen.dart';

class RedeList extends StatefulWidget {
  final String occupation;

  RedeList(this.occupation, {Key key}) : super(key: key);

  @override
  RedeListState createState() => RedeListState(occupation);
}

class RedeListState extends State<RedeList> {
  bool searching = false;
  TextEditingController _searchController = TextEditingController();
  String search = "";

  final String occupation;

  RedeListState(this.occupation);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: occupation,
      body: occupation == "Favoritos"
          ? _buildFavorites(context)
          : _buildBody(context),
      actions: <IconButton>[
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () => toggleSearch(),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(User.collectionName)
          .where("ocupacao", isEqualTo: this.occupation)
          .where("ativo", isEqualTo: 1)
          .orderBy("nome")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        if (snapshot.data.documents.length == 0)
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Não há usuários nessa categoria"),
            ],
          );

        return _buildList(context, snapshot.data.documents);
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
    User user;
    Institution institution;

    if (data.data['tipo'] == UserType.person.index) {
      user = User.fromMap(data.data, reference: data.reference);
      if (!user.name.toLowerCase().contains(search) &&
          !user.description.toLowerCase().contains(search)) return Container();
    } else {
      institution = Institution.fromMap(data.data, reference: data.reference);
      if (!institution.name.toLowerCase().contains(search) &&
          !institution.description.toLowerCase().contains(search))
        return Container();
    }

    return SimpleListItem(
      user != null ? user.name : institution.name,
      user != null
          ? () => callbackUser(context, user)
          : () => callbackInstitution(context, institution),
      textColor: Style.darkText,
      key: ValueKey(data.documentID),
    );
  }

  Widget _buildFavorites(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: MyApp.getUserReference()
          .collection(Favorite.collectionName)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        if (snapshot.data.documents.length == 0)
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Você ainda não salvou favoritos"),
            ],
          );

        return _buildFavoritesList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildFavoritesList(
      BuildContext context, List<DocumentSnapshot> snapshot) {
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
          ]..addAll(snapshot
              .where((snap) =>
                  snap.data['classe'] == 'Instituicao' ||
                  snap.data['classe'] == 'Usuario')
              .map((data) => _FavoriteItem(data['id']))
              .toList()),
        ),
      ),
    ]);
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

class _FavoriteItem extends StatefulWidget {
  final String userId;

  _FavoriteItem(this.userId) : super(key: Key(userId));

  @override
  _FavoriteItemState createState() => _FavoriteItemState();
}

class _FavoriteItemState extends State<_FavoriteItem> {
  User user;
  Institution institution;

  @override
  void initState() {
    super.initState();
    Firestore.instance
        .collection(User.collectionName)
        .document(widget.userId)
        .get()
        .then((DocumentSnapshot snapshot) {
      setState(() {
        if (snapshot.data['tipo'] == UserType.institution.index) {
          institution =
              Institution.fromMap(snapshot.data, reference: snapshot.reference);
        } else {
          user = User.fromMap(snapshot.data, reference: snapshot.reference);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null && institution == null) {
      return Container();
    }

    Widget icon;
    if (institution != null) {
      if (institution.email == Helper.emailLabdis) {
        icon = Image.asset(
          "images/icones/ic_labdis.png",
          height: 35.0,
        );
      } else if (institution.occupation == Occupation.laboratorio) {
        icon = Image.asset(
          "images/icones/ic_laboratorio.png",
          height: 35.0,
        );
      } else if (institution.occupation == Occupation.escola) {
        icon = Image.asset(
          "images/icones/ic_escola.png",
          height: 35.0,
        );
      } else if (institution.occupation == Occupation.incubadora) {
        icon = Image.asset(
          "images/icones/ic_incubadora.png",
          height: 35.0,
        );
      } else if (institution.occupation == Occupation.empreendedor) {
        icon = Image.asset(
          "images/icones/ic_empreendedor.png",
          height: 35.0,
        );
      }
    }

    return SimpleListItem(
      user != null ? user.name : institution.name,
      user != null
          ? () => callbackUser(context, user)
          : () => callbackInstitution(context, institution),
      textColor: Style.darkText,
      iconExtra: icon,
    );
  }
}

void callbackUser(BuildContext context, User user) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePerson(user),
    ),
  );
}

void callbackInstitution(BuildContext context, Institution institution) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfileInstitution(institution),
    ),
  );
}
