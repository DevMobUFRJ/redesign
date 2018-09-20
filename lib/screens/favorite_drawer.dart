import 'package:flutter/material.dart';

class FavoriteDrawer extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    return new Opacity(opacity: 0.4,
      child :new Drawer(
        child: new ListView(
          children: <Widget>[
          ],
        ),
      ),
    );
  }
}
//          new ListTile(
//            leading: new Icon(Icons.map),
//            title: new Text('Pessoas',
//              style: new TextStyle(
//                  color: Colors.black45),),
//          ),
//          new ListTile(
//            leading: new Icon(Icons.person),
//            title: new Text("Perfil",
//              style: new TextStyle(
//                  color: Colors.black45),),
//          ),
//          new ListTile(
//            leading: new Icon(Icons.star),
//            title: new Text("Fovoritos",
//              style: new TextStyle(
//                  color: Colors.black45),),
//          ),
//          new ListTile(
//            leading: new Icon(Icons.list),
//            title: new Text("Materiais",
//              style: new TextStyle(
//                  color: Colors.black45),),
//          ),
//          new ListTile(
//            leading: new Icon(Icons.people),
//            title: new Text("Usuários",
//              style: new TextStyle(
//                  color: Colors.black45),
//            ),
//          ),
//          new ListTile(
//            leading: new Icon(Icons.exit_to_app),
//            title: new Text("Sair",
//              style: new TextStyle(
//                  color: Colors.black45),
//            ),
//          ),
