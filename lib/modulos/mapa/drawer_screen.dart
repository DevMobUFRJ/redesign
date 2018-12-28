import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:redesign/modulos/rede/rede_tela.dart';
import 'package:redesign/modulos/eventos/eventos_lista.dart';

class DrawerScreen extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width:160.0 ,
                  margin: EdgeInsets.all(10.0),
                  child: Column (
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Nome',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal, fontSize: 25.0),
                      ),
                      Text('Ocupação',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal, fontSize: 17.0),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget> [
                            RoundIconButton(
                              icon: Icon(Icons.edit),
                              iconColor: Colors.white,
                              circleColor: Color(0xff00838f),
                              size: 40.0,
                            ),
                            RoundIconButton(
                              icon: Icon(Icons.chat_bubble),
                              iconColor: Colors.white,
                              circleColor: Color(0xff00838f),
                              size: 40.0,
                              onPressed: (){print("yo");},
                            ),
                            RoundIconButton(
                              icon: Icon(Icons.exit_to_app),
                              iconColor: Colors.white,
                              circleColor: Color(0xff00838f),
                              size: 40.0,
                              onPressed: () => print("oi"),
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
              color: Colors.black
          ),
        ),
        ListaDrawer(
          icon: Icons.directions,
          iconColor: Color(0xff00838f),
          text: 'Mapa',
          onPressed: () {}
        ),
        ListaDrawer(
          icon: Icons.people,
          iconColor: Color(0xff00838f),
          text: 'Rede',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RedeTela())
            );
          }
        ),
        ListaDrawer(
          icon: Icons.chat_bubble,
          iconColor: Color(0xff00838f),
          text: 'Fórum',
          onPressed: () {}
        ),
        ListaDrawer(
          icon: Icons.collections_bookmark,
          iconColor: Color(0xff00838f),
          text: 'Materiais',
          onPressed: () {}
        ),
        ListaDrawer(
          icon: Icons.calendar_today,
          iconColor: Color(0xff00838f),
          text: 'Eventos',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventosTela())
              );
            }
        ),
        ListaDrawer(
          icon: Icons.exit_to_app,
          iconColor: Color(0xff00838f),
          text: 'Sair',
            onPressed: () {
              logout(context);
            }
        ),
      ],
    ),
    );
  }

  logout(BuildContext context) {
    print("Quer sair");
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.signOut().then((dynamic) => Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName))).catchError((e) => print(e));
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
      child: IconButton(alignment: Alignment.center,
            icon: icon,
            disabledColor: iconColor,
          onPressed: null
      ),
    );
  }
}

class ListaDrawer extends StatelessWidget{
  final IconData icon;
  final Color iconColor;
  final String text;
  final VoidCallback onPressed;

  ListaDrawer({
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
