import 'package:flutter/material.dart';

class FavoriteDrawer extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child:new Container(
        color: Color.fromARGB(10, 0, 255, 255),
        child:new ListView(
          children: <Widget>[
          ],
        ),
      ),
    );
  }
}