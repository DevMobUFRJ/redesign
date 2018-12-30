import 'package:flutter/material.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/login/login.dart';
import 'package:redesign/modulos/mapa/mapa_tela.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: Tema.principal,
      home: Login(),

      routes: <String, WidgetBuilder>{
        '/mapa': (context) => MapaTela(),
      },
    );
  }
}
