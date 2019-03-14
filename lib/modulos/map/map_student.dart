import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_tap_coordinates/image_tap_coordinates.dart';
import 'package:url_launcher/url_launcher.dart';

List<dynamic> _mapAreas;

class MapStudent extends StatefulWidget {

  MapStudent(BuildContext context){
    loadMapAreas(context);
  }

  @override
  _MapStudentState createState() => _MapStudentState();

  void loadMapAreas(BuildContext context) async{
    String coordinates = await DefaultAssetBundle.of(context).loadString("assets/MapStudentCoordinates.json");
    _mapAreas = jsonDecode(coordinates);
  }
}

class _MapStudentState extends State<MapStudent> {

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
        tapCallback: (Offset coordinates){
          _touchedMap(coordinates);
        },
      ),
    );
  }

  void _touchedMap(Offset coordinates){
    for(dynamic element in _mapAreas){
      if(coordinates.dx >= element['topLeft']['x']
          && coordinates.dx <= element['bottomRight']['x']
          && coordinates.dy >= element['topLeft']['y']
          && coordinates.dy <= element['bottomRight']['y'] ){
        _dialogClickedPosition(element);
        return;
      }
    }
  }

  Future<void> _dialogClickedPosition(dynamic element) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(element["tema"]?.toString() ?? ""),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Por: ' + (element['escola']?.toString() ?? "") + '\n'
                    'Ano: ' + (element['ano']?.toString() ?? "") + '\n'
                    'Turma: ' + (element['turma']?.toString() ?? "")),
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
                _launchURL(element['uriString']);
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
