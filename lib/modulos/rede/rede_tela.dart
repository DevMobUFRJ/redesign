import 'package:flutter/material.dart';
import 'package:redesign/widgets/tela_base.dart';

class RedeTela extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return TelaBase (
      title: "Rede",
      body: Center(
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
