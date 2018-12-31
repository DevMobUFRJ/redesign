import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:redesign/modulos/mapa/drawer_screen.dart';
import 'package:redesign/modulos/mapa/filter_drawer.dart';
import 'package:redesign/servicos/meu_app.dart';

class MapaTela extends StatefulWidget {
  MapaTela({Key key}) : super(key: key);

  @override
  _MapaTelaState createState() => _MapaTelaState();
}

class _MapaTelaState extends State<MapaTela> {
  GoogleMapController mapController;

  _MapaTelaState(){
    MeuApp.startup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerScreen(),
      appBar: AppBar(
        title: Text("REDEsign"),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ],
      ),
      endDrawer: FiltroDrawer(),
      body: GoogleMap(
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
