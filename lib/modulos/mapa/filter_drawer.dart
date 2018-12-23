import 'package:flutter/material.dart';

class FiltroDrawer extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Drawer(
        child: Container(
          color: Color.fromARGB(10, 0, 255, 255),
          child: ListView(
            children: <Widget>[
              Text("placeholder")
            ],
          ),
        ),
      )
    );
  }
}