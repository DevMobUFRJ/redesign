import 'package:flutter/material.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/login/login.dart';
import 'package:redesign/modulos/mapa/mapa_tela.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: Tema.principal,
      home: Login(),
      routes: <String, WidgetBuilder>{
        '/mapa': (context) => new MapaTela()
      },
    );
  }
}
