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
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: body
    );
  }

}