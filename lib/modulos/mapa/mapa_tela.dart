import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:redesign/modulos/mapa/drawer_screen.dart';
import 'package:redesign/modulos/mapa/filter_drawer.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_instituicao.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/servicos/helper.dart';
import 'package:redesign/servicos/meu_app.dart';

class MapaTela extends StatefulWidget {
  MapaTela({Key key}) : super(key: key);

  @override
  _MapaTelaState createState() => _MapaTelaState();
}

class _MapaTelaState extends State<MapaTela> {
  GoogleMapController mapController;
  List<Marker> marcadores = [];
  List<Instituicao> instituicoes = [];
  Marker _selectedMarker;

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
    mapController = controller;
    mapController.onInfoWindowTapped.add(_infoTapped);
    getInstituicoesColocaMarcadores();
    setState(() {
      controller.moveCamera(CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: LatLng(-22.8544375, -43.2296038),
          zoom: 12.0,
        ),
      ));
    });
  }

  void _updateMarker(MarkerOptions changes) {
    mapController.updateMarker(_selectedMarker, changes);
  }

  void _infoTapped(Marker marker){
    Instituicao instituicao = instituicoes[marcadores.indexOf(marker)];
    Navigator.push(
        context,
        MaterialPageRoute(builder:(context) =>
          // Apesar de empreendedores serem do tipo Instituição p/ ter lat-lng,
          // a visualização é de pessoa.
          instituicao.ocupacao != Ocupacao.empreendedor ?
            PerfilInstituicao(instituicao)
            : PerfilPessoa(instituicao)),
    );
  }

  getInstituicoesColocaMarcadores(){
    Stream<QuerySnapshot> query = Firestore.instance.collection(Usuario.collectionName)
        .where("tipo", isEqualTo: TipoUsuario.instituicao.index).snapshots();
    query.forEach((element){
      for(DocumentSnapshot d in element.documents){
        Instituicao instituicao = Instituicao.fromMap(d.data, reference: d.reference);

        if(instituicao.lat == 0 || instituicao.lng == 0) continue;

        String icone = "";
        if(instituicao.email == Helper.emailLabdis){
          icone = "labdis";
        } else if (instituicao.ocupacao == Ocupacao.incubadora) {
          icone = "incubadora";
        } else if (instituicao.ocupacao == Ocupacao.escola) {
          icone = "escola";
        } else if (instituicao.ocupacao == Ocupacao.laboratorio) {
          icone = "laboratorio";
        } else if (instituicao.ocupacao == Ocupacao.empreendedor) {
          icone = "empreendedor";
        }

        LatLng center = LatLng(instituicao.lat, instituicao.lng);
        mapController.addMarker(
          MarkerOptions(
            position: center,
            infoWindowText: InfoWindowText(instituicao.nome, "Detalhes"),
            icon: BitmapDescriptor.fromAsset("images/icones/ic_" + icone + ".png"),
        )).then((marker) {
          marcadores.add(marker);
          instituicoes.add(instituicao);
        });
      }
    });
  }
}
