import 'package:flutter/material.dart';

class TelaBase extends StatelessWidget {

  final String title;
  final Widget body;
  final FloatingActionButton fab;
  final IconButton searchButton;

  TelaBase({this.title, this.body, this.fab, this.searchButton});

  bool notNull(Object o) => o != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          searchButton,
          IconButton(
            icon: Icon(
              Icons.home,
              color: Colors.white,
            ),
            onPressed: () => homePressed(context),
          )
        ].where(notNull).toList(),//permite que searchButton seja null
      ),
      body: Padding(
          padding: EdgeInsets.all(16),
          child: body
      ),
      floatingActionButton: fab,
    );
  }

  void homePressed(context){
    Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
  }

}