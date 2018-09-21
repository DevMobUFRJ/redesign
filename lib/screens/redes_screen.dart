import 'package:flutter/material.dart';

class Redes_screen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Rede'),
        backgroundColor: new Color.fromARGB(255, 55, 116, 127),
      ),
      body: new Center(
        child: new Container(
          margin: new EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
          child: new Column(
            children: <Widget>[
              new Lista(text:'Favoritos'),
              new Divider(height: 1.0,color: Colors.black45,),
              new Lista(text:'Laboratórios'),
              new Divider(height: 1.0,color: Colors.black45,),
              new Lista(text:'Escolas'),
              new Divider(height: 1.0,color: Colors.black45,),
              new Lista(text:'Incubadoras'),
              new Divider(height: 1.0,color: Colors.black45,),
            ],
          ),
        ),
      ),
    );
  }
}

class Lista extends StatelessWidget{

  final String text;
  final VoidCallback onPressed;

  Lista({
    this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(text,
        style: new TextStyle(
          color: new Color.fromARGB(255, 55, 116, 127),
          fontSize: 25.0,
        ),
      ),
      onTap: onPressed,
    );
  }
}
