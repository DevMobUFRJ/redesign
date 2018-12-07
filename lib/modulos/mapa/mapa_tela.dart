import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:redesign/modulos/mapa/drawer_screen.dart';
import 'package:redesign/modulos/mapa/filter_drawer.dart';

class MapaTela extends StatefulWidget {
  MapaTela({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MapaTelaState createState() => new _MapaTelaState();
}

class _MapaTelaState extends State<MapaTela> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: new DrawerScreen(),
      appBar: new AppBar(
        title: new Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
//        actions: <Widget>[
//          new IconButton(
//              icon: new Icon(
//                Icons.star_border,
//                color: Colors.white,),
//              onPressed: () => _scaffoldKey.currentState.openEndDrawer
//          ),
//        ],
      ),
      endDrawer: new FavoriteDrawer(),
      body: new  GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-22.8544375, -43.2296038),
          zoom: 12.0,
        ),
        onMapCreated: _onMapCreated,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      controller.moveCamera(CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: LatLng(-22.8544375, -43.2296038),
          zoom: 12.0,
        ),
      ));
      mapController = controller;
    });
  }
}
