import 'package:flutter/material.dart';

class TelaBase extends StatelessWidget {

  final String title;
  final Widget body;

  TelaBase({this.title, this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Text(title),
        backgroundColor: Color.fromARGB(255, 55, 116, 127),
      ),
      body: body
    );
  }

}