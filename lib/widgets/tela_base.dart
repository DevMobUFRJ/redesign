import 'package:flutter/material.dart';

class TelaBase extends StatelessWidget {

  final String title;
  final Widget body;
  final FloatingActionButton fab;

  TelaBase({this.title, this.body, this.fab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: body,
      floatingActionButton: fab,
    );
  }

}