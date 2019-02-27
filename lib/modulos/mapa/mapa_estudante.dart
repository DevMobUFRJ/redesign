import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_tap_coordinates/image_tap_coordinates.dart';
import 'package:url_launcher/url_launcher.dart';

List<dynamic> _areasDoMapa;

class MapaEstudante extends StatefulWidget {

  MapaEstudante(BuildContext context){
    carregarAreasDoMapa(context);
  }

  @override
  _MapaEstudanteState createState() => _MapaEstudanteState();

  void carregarAreasDoMapa(BuildContext context) async{
    String coordenadas = await DefaultAssetBundle.of(context).loadString("assets/MapStudentCoordinates.json");
    _areasDoMapa = jsonDecode(coordenadas);
  }
}

class _MapaEstudanteState extends State<MapaEstudante> {

  ImageTapController _controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ImageTapCoordinates(
        AssetImage("images/mapa_rede.png"),
        backgroundColor: Colors.white,
        controller: _controller,
        initScale: 0.133,
        minScale: 0.056,
        maxScale: 0.8,
        tapCallback: (Offset coordenadas){
          _tocouNoMapa(coordenadas);
        },
      ),
    );
  }

  void _tocouNoMapa(Offset coordenadas){
    for(dynamic elemento in _areasDoMapa){
      if(coordenadas.dx >= elemento['topLeft']['x']
          && coordenadas.dx <= elemento['bottomRight']['x']
          && coordenadas.dy >= elemento['topLeft']['y']
          && coordenadas.dy <= elemento['bottomRight']['y'] ){
        _posicaoClicadaDialog(elemento);
        return;
      }
    }
  }

  Future<void> _posicaoClicadaDialog(dynamic elemento) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(elemento["tema"]?.toString() ?? ""),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Por: ' + (elemento['escola']?.toString() ?? "") + '\n'
                    'Ano: ' + (elemento['ano']?.toString() ?? "") + '\n'
                    'Turma: ' + (elemento['turma']?.toString() ?? "")),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Ver Recurso'),
              onPressed: () {
                _launchURL(elemento['uriString']);
              },
            ),
          ],
        );
      },
    );
  }

  void _launchURL(String url) async{
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
