import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/fb_icon_icons.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/chat/chat_screen.dart';
import 'package:redesign/modulos/user/favorite.dart';
import 'package:redesign/modulos/user/institution.dart';
import 'package:redesign/modulos/user/profile_person.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/async_data.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:redesign/services/helper.dart';

class ProfileInstitution extends StatefulWidget {
  final Institution institution;

  ProfileInstitution(this.institution);

  @override
  _ProfileInstitutionState createState() =>
      _ProfileInstitutionState(institution);
}

class _ProfileInstitutionState extends State<ProfileInstitution> {
  final Institution institution;
  bool isFavorite = false;

  _ProfileInstitutionState(this.institution) {
    MyApp.getUserReference()
        .collection(Favorite.collectionName)
        .where("id", isEqualTo: institution.reference.documentID)
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

  bool isBeingUsed = false;
  void toggleFavorite() {
    if (isBeingUsed) return;
    isBeingUsed = true;
    MyApp.getUserReference()
        .collection(Favorite.collectionName)
        .where("id", isEqualTo: institution.reference.documentID)
        .snapshots()
        .first
        .then((QuerySnapshot empty) {
      if (empty.documents.length == 0) {
        MyApp.getUserReference()
            .collection(Favorite.collectionName)
            .add((new Favorite(
                    id: institution.reference.documentID,
                    className: institution.runtimeType.toString())
                .toJson()))
            .then((v) {
          setState(() {
            isFavorite = true;
          });
          isBeingUsed = false;
        }).catchError((e) {});
      } else {
        empty.documents.first.reference.delete().then((v) {
          setState(() {
            isFavorite = false;
          });
          isBeingUsed = false;
        }).catchError((e) {});
      }
    }).catchError((e) {});
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Perfil",
      body: ListView(
        children: <Widget>[_body()],
      ),
      fab: institution.reference.documentID != MyApp.userId()
          ? FloatingActionButton(
              child: Icon(Icons.chat_bubble),
              backgroundColor: Style.main.primaryColor,
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                            null,
                            otherUser: institution,
                          ))),
            )
          : null,
    );
  }

  Widget _body() {
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Hero(
                    tag: institution.reference.documentID,
                    child: CircleAvatarAsync(
                      institution.reference.documentID,
                      radius: 30,
                    )),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Text(
                      institution.name,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 20,
                          color: Style.primaryColor,
                          fontWeight: FontWeight.w500),
                      maxLines: 2,
                    ),
                  ),
                ),
                GestureDetector(
                  child: Icon(
                    Icons.directions,
                    size: 28,
                    color: institution.lat == 0 || institution.lng == 0
                        ? Colors.black26
                        : Style.primaryColor,
                  ),
                  onTap: () async {
                    if (institution.lat == 0 || institution.lng == 0) return;

                    String urlAndroid = "geo:0,0?q=" +
                        Uri.encodeQueryComponent(
                            institution.address + " - " + institution.city);
                    String urlIos = "http://maps.apple.com/?address=" +
                        Uri.encodeFull(
                            institution.address + " - " + institution.city);
                    if (await canLaunch(urlAndroid)) {
                      launch(urlAndroid);
                    } else if (await canLaunch(urlIos)) {
                      launch(urlIos);
                    }
                  },
                ),
                IconButton(
                  icon: isFavorite
                      ? Icon(
                          Icons.star,
                          color: Style.primaryColor,
                        )
                      : Icon(
                          Icons.star_border,
                          color: Style.primaryColor,
                        ),
                  iconSize: 28,
                  onPressed: () => toggleFavorite(),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 5, right: 5, top: 15),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                      child: personalNetworks(Icons.email, institution.email)),
                  onTap: () => _launchURL("mailto:" +
                      institution.email +
                      "?subject=Contato%20pelo%20REDEsign"),
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(top: 15),
                    child: institution.site.isEmpty
                        ? null
                        : personalNetworks(Icons.public, institution.site),
                  ),
                  onTap: institution.site.isEmpty
                      ? null
                      : () => _launchURL(institution.site),
                ),
                GestureDetector(
                  child: Container(
                      padding: EdgeInsets.only(top: 15),
                      child: institution.facebook.isEmpty
                          ? null
                          : personalNetworks(
                              FbIcon.facebook_official, institution.facebook)),
                  onTap: institution.facebook.isEmpty
                      ? null
                      : () => _launchURL(institution.facebook),
                ), // email
                // facebook
              ],
            ),
          ),
          // Se o método retornar "", então esconde um divider e esconde a lista secundária
          Helper.getSecondaryOccupationTitle(institution.occupation) == ""
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Divider(
                    color: Colors.black54,
                  ),
                ),
          Helper.getSecondaryOccupationTitle(institution.occupation) == ""
              ? Container()
              : ExpansionTile(
                  title: Text(
                    Helper.getSecondaryOccupationTitle(institution.occupation),
                    style: TextStyle(color: Colors.black87, fontSize: 22),
                  ),
                  children: <Widget>[
                    Divider(
                      color: Colors.black54,
                    ),
                    _UsersList(
                        Helper.getSecondaryOccupationToInstitution(
                            institution.occupation),
                        institution.reference.documentID),
                  ],
                ),
          Divider(
            color: Colors.black54,
          ),
          ExpansionTile(
            title: Text(
              Helper.getPrimaryOccupationTitle(institution.occupation),
              style: TextStyle(color: Colors.black87, fontSize: 22),
            ),
            children: <Widget>[
              Divider(
                color: Colors.black54,
              ),
              _UsersList(
                  Helper.getOcupacaoPrimariaParaInstituicao(
                      institution.occupation),
                  institution.reference.documentID),
            ],
          ),
          Divider(
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget personalNetworks(IconData icon, String info) {
    return Row(
      children: <Widget>[
        Container(
          child: Icon(
            icon,
            color: Style.buttonBlue,
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 15),
        ),
        Text(
          info,
          style: TextStyle(fontSize: 15, color: Colors.black54),
        )
      ],
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}

class _UsersList extends StatefulWidget {
  /// Título da ocupação das pessoas que deseja listar. Ex: Bolsista.
  final String occupation;

  /// ID da instituição onde buscamos pessoas com aquela ocupação.
  final String institutionId;

  _UsersList(this.occupation, this.institutionId);

  @override
  _UsersListState createState() =>
      _UsersListState(occupation, institutionId);
}

class _UsersListState extends State<_UsersList> {
  final String occupation;
  final String institutionId;

  _UsersListState(this.occupation, this.institutionId);

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(User.collectionName)
          .where("ocupacao", isEqualTo: occupation)
          .where("instituicaoId", isEqualTo: institutionId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(
        children: snapshot.length == 0
            ? [Text("Nenhum cadastrado")]
            : snapshot.map((data) => _buildListItem(context, data)).toList());
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final User user = User.fromMap(data.data, reference: data.reference);

    return ListTile(
      key: ValueKey(data.reference.documentID),
      title: Text(
        user.name,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        maxLines: 2,
        overflow: TextOverflow.clip,
      ),
      leading: Hero(
          tag: user.reference.documentID,
          child:
              CircleAvatarAsync(user.reference.documentID, clickable: true)),
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePerson(user),
            ),
          ),
    );
  }
}
