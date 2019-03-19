import 'package:flutter/material.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/auth/auth.dart';
import 'package:redesign/modulos/chat/chat_list.dart';
import 'package:redesign/modulos/forum/forum_tema_lista.dart';
import 'package:redesign/modulos/map/map_student.dart';
import 'package:redesign/modulos/material/material_lista.dart';
import 'package:redesign/modulos/rede/rede_tela.dart';
import 'package:redesign/modulos/events/events_list.dart';
import 'package:redesign/modulos/about/about_screen.dart';
import 'package:redesign/modulos/user/profile_form.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/services/my_app.dart';

class DrawerScreen extends StatefulWidget {
  final int unreadMessages;

  DrawerScreen({this.unreadMessages=0});

  @override
  DrawerScreenState createState() => DrawerScreenState();
}

class DrawerScreenState extends State<DrawerScreen> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          DrawerHeader(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => MyApp.gotoProfile(context),
                    child: Hero(
                      tag: MyApp.userId(),
                      child: Container(
                        width: 90.0,
                        height: 90.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: MyApp.imageMemory == null ?
                                AssetImage("images/perfil_placeholder.png") :
                                MemoryImage(MyApp.imageMemory),
                          )
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width:160.0 ,
                    margin: EdgeInsets.all(10.0),
                    child: Column (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(MyApp.name(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                            maxLines: 1,
                          ),
                        ),
                        Text(MyApp.occupation(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal, fontSize: 16.0),
                          maxLines: 1,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget> [
                              RoundIconButton(
                                icon: Icon(Icons.edit),
                                iconColor: Colors.white,
                                circleColor: Color(0xff00838f),
                                size: 40.0,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ProfileForm())
                                  );
                                },
                              ),
                              MyApp.isStudent() ? Container() :
                              MessageIconButton(
                                unreadMessages: widget.unreadMessages,
                                icon: Icon(Icons.chat_bubble),
                                iconColor: Colors.white,
                                circleColor: Color(0xff00838f),
                                size: 40.0,
                                onPressed:  () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ChatList())
                                  );
                                }
                              ),
                              RoundIconButton(
                                icon: Icon(Icons.exit_to_app),
                                iconColor: Colors.white,
                                circleColor: Color(0xff00838f),
                                size: 40.0,
                                onPressed: () => logout(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
                color: Style.darkBackground
            ),
          ),
          DrawerList(
            icon: Icons.explore,
            iconColor: Style.primaryColor,
            text: 'Mapa',
            onPressed: () {
              Navigator.pop(context);
            }
          ),
          MyApp.occupation() != Occupation.professor ? Container() : DrawerList(
            icon: Icons.explore,
            iconColor: Style.primaryColor,
            text: 'Mapa do Pegada',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapStudent(context))
              );
            }
          ),
          DrawerList(
            icon: Icons.people,
            iconColor: Style.primaryColor,
            text: 'Rede',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RedeTela())
              );
            }
          ),
          DrawerList(
            icon: Icons.forum,
            iconColor: Style.primaryColor,
            text: 'Fórum',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForumTemaLista())
              );
            }
          ),
          DrawerList(
            icon: Icons.library_books,
            iconColor: Style.primaryColor,
            text: 'Materiais',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MaterialLista())
                );
              }
          ),
          DrawerList(
            icon: Icons.event,
            iconColor: Style.primaryColor,
            text: 'Eventos',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventsScreen())
              );
            }
          ),
          MyApp.isLabDis() ?
          DrawerList(
            icon: Icons.assignment_ind,
            iconColor: Style.primaryColor,
            text: 'Autorizar Usuários',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthScreen())
              );
            }
          ) : Container(),
          Expanded(child: Container()),
          Container(
            // This align moves the children to the bottom
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  // This container holds all the children that will be aligned
                  // on the bottom and should not scroll with the above ListView
                  child: Container(
                      child: Column(
                        children: <Widget>[
                          Divider(color: Colors.black54, height: 0,),
                          DrawerList(
                            icon: Icons.help,
                            iconColor: Style.primaryColor,
                            text: 'Sobre',
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AboutScreen())
                              );
                            },
                          )
                        ],
                      )
                  )
              )
          ),
        ],
      ),
    );
  }

  logout(BuildContext context) {
    MyApp.logout(context);
  }
}

class RoundIconButton extends StatelessWidget {
  final Icon icon;
  final Color iconColor;
  final Color circleColor;
  final double size;
  final VoidCallback onPressed;

  RoundIconButton({
    this.icon,
    this.iconColor,
    this.circleColor,
    this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: circleColor,
      ),
      child: IconButton(
        alignment: Alignment.center,
        icon: icon,
        color: iconColor,
        onPressed: onPressed,
      ),
    );
  }
}

class DrawerList extends StatelessWidget{
  final IconData icon;
  final Color iconColor;
  final String text;
  final VoidCallback onPressed;

  DrawerList({
    this.icon,
    this.iconColor,
    this.text,
    this.onPressed,
});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: iconColor,),
      title: Text(text,
        style: TextStyle(
          color: Colors.black45),
      ),
      onTap: onPressed,
    );
  }
}

class MessageIconButton extends StatelessWidget {
  final int unreadMessages;
  final Icon icon;
  final Color iconColor;
  final Color circleColor;
  final double size;
  final VoidCallback onPressed;

  MessageIconButton({
    this.icon,
    this.iconColor,
    this.circleColor,
    this.size,
    this.onPressed,
    @required this.unreadMessages,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
            ),
            child: IconButton(
              alignment: Alignment.center,
              icon: icon,
              color: iconColor,
              onPressed: onPressed,
            ),
          ),
        ),
        unreadMessages == 0 ? Container() : CircleAvatar(
          radius: 10,
          backgroundColor: Colors.red,
          child: Text(unreadMessages.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}