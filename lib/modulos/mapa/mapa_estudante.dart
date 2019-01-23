import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';

class MapaEstudante extends StatefulWidget {
  @override
  _MapaEstudanteState createState() => _MapaEstudanteState();
}

class _MapaEstudanteState extends State<MapaEstudante> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GestureDetector(
        child: PhotoView(
          backgroundDecoration: BoxDecoration(
            color: Colors.white,
          ),
          imageProvider: AssetImage("images/mapa_rede.png"),
          minScale: PhotoViewComputedScale.contained,
          initialScale: PhotoViewComputedScale.contained * 2.8,
          maxScale: PhotoViewComputedScale.contained * 4,
        ),
        onTapDown: (tapDownDetails) => print(tapDownDetails.globalPosition),
      ),
    );
  }

}
