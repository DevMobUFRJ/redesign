import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {

  BuildContext context;

  final String title;
  final Widget body;
  final FloatingActionButton fab;
  final List<IconButton> extraActions = [];
  final EdgeInsets bodyPadding;

  BaseScreen({@required this.title, this.body, this.fab,
    this.bodyPadding=const EdgeInsets.fromLTRB(16, 8, 16, 0),
    actions
  }){
    if(actions != null){
      this.extraActions.addAll(actions);
    }
    extraActions.add(
      IconButton(
        tooltip: "Início",
        icon: Icon(
          Icons.home,
          color: Colors.white,
        ),
        onPressed: () => homePressed()
      )
    );
  }

  bool notNull(Object o) => o != null;

  @override
  Widget build(BuildContext context) {
    this.context = context;

    return Scaffold(
      appBar:  AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
        actions: extraActions.where(notNull).toList(),//permite que searchButton seja null
      ),
      body: Padding(
          padding: bodyPadding,
          child: body
      ),
      floatingActionButton: fab,
    );
  }

  void homePressed(){
    Navigator.popUntil(context,
        ModalRoute.withName('/')
    );
  }
}