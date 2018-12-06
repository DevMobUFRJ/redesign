import 'package:flutter/material.dart';

class PadraoScreen extends StatelessWidget {

  final String title;
  final Widget body;

  PadraoScreen({this.title, this.body});

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