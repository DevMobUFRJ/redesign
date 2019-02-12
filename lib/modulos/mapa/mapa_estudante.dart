import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_tap_coordinates/image_tap_coordinates.dart';

class MapaEstudante extends StatefulWidget {
  @override
  _MapaEstudanteState createState() => _MapaEstudanteState();
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
        tapCallback: (Offset tapCoordinates){
          print(tapCoordinates);
        },
      ),
    );

  }
}
