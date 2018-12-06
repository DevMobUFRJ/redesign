import 'package:flutter/material.dart';
import 'package:teste/screens/drawer_screen.dart';
import 'package:teste/screens/favorite_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'REDEsign'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: new DrawerScreen(),
      appBar: new AppBar(
        title: new Text(widget.title),
        backgroundColor: new Color.fromARGB(255, 55, 116, 127),
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
