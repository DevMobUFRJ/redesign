import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:redesign/styles/fb_icon_icons.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/chat/chat_screen.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/async_data.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePerson extends StatefulWidget {
  final User user;

  ProfilePerson(this.user);

  @override
  _ProfilePersonState createState() => _ProfilePersonState(user);
}

class _ProfilePersonState extends State<ProfilePerson> {
  final User user;

  _ProfilePersonState(this.user);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Perfil",
      body: ListView(
        children: <Widget>[_body()],
      ),
      fab: user.reference.documentID != MyApp.userId() && !MyApp.isStudent()
          ? FloatingActionButton(
              child: Icon(Icons.chat_bubble),
              backgroundColor: Style.main.primaryColor,
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                            null,
                            otherUser: user,
                          ))),
            )
          : null,
    );
  }

  Widget _body() {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Hero(
                        tag: user.reference.documentID,
                        child: CircleAvatarAsync(
                          user.reference.documentID,
                          radius: 40.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          user.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          user.occupation,
                          style: TextStyle(fontSize: 15),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 15, left: 15, right: 15),
                  child: Text(
                    user.description.isEmpty
                        ? "Nenhuma descrição"
                        : user.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ), // Descrição
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15, bottom: 15),
            child: Divider(
              color: Colors.black54,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child:
                      Container(child: personalNetworks(Icons.email, user.email)),
                  onTap: () => _launchURL("mailto:" +
                      user.email +
                      "?subject=Contato%20pelo%20REDEsign"),
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(top: 15),
                    child: user.site.isEmpty
                        ? null
                        : personalNetworks(Icons.public, user.site),
                  ),
                  onTap: user.site.isEmpty ? null : () => _launchURL(user.site),
                ),
                GestureDetector(
                  child: Container(
                      padding: EdgeInsets.only(top: 15),
                      child: user.facebook.isEmpty
                          ? null
                          : personalNetworks(
                              FbIcon.facebook_official, user.facebook)),
                  onTap: user.facebook.isEmpty
                      ? null
                      : () => _launchURL(user.facebook),
                ), // email
                // facebook
              ],
            ),
          )
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
        Text(info, style: TextStyle(fontSize: 15, color: Colors.black54))
      ],
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
