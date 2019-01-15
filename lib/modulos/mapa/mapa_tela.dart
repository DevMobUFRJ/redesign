import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/mapa/drawer_screen.dart';
import 'package:redesign/modulos/mapa/mapa_estudante.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_pessoa.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/servicos/helper.dart';
import 'package:redesign/servicos/meu_app.dart';

FirebaseUser mCurrentUser;

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
  _FiltroDrawer filtro = _FiltroDrawer();
  bool mapaCarregou = false;
  bool temUsuario = false;

  @override
  void initState() {
    super.initState();
    if(MeuApp.userId() == null) {
      _getCurrentUser();
    } else {
      temUsuario = true;
    }
  }

  /// Tenta logar o usuário pegando do cache logo ao criar a tela
  _getCurrentUser() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser _currentUser = await _auth.currentUser();
    if(_currentUser != null){
      authSucesso(_currentUser);
    } else {
      erroEncontrarUsuario(null);
    }
  }

  /// Usuario já estava em cache, então vai pro mapa.
  void authSucesso(FirebaseUser user){
    mCurrentUser = user;
    MeuApp.firebaseUser = user;
    Firestore.instance.collection(Usuario.collectionName).document(user.uid).get()
        .then(encontrouUsuario).catchError(erroEncontrarUsuario);
  }

  void encontrouUsuario(DocumentSnapshot snapshot){
    if(snapshot.data['tipo'] == TipoUsuario.instituicao.index){
      MeuApp.setUsuario(Instituicao.fromMap(snapshot.data, reference: snapshot.reference));
    } else {
      MeuApp.setUsuario(Usuario.fromMap(snapshot.data, reference: snapshot.reference));
    }
    // Finalmente pode fazer o que tem que fazer.
    setState((){
      temUsuario = true;
    });
    MeuApp.startup();
    getInstituicoesColocaMarcadores();
  }

  void erroEncontrarUsuario(e){
    Navigator.pushReplacementNamed(
        context,
        '/login'
    );
  }

  @override
  Widget build(BuildContext context) {
    if(!temUsuario){
      return Scaffold(
        body: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Tema.darkBackground,
                child: Center(
                  child: CircularProgressIndicator(),
                ),),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: DrawerScreen(),
      appBar: AppBar(
        title: Text("REDEsign"),
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        actions: MeuApp.ehEstudante() ? null : [
          Builder(
            builder: (context) =>
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  tooltip: MaterialLocalizations
                      .of(context)
                      .openAppDrawerTooltip,
                ),
          ),
        ],
      ),
      endDrawer: MeuApp.ehEstudante() ? null : filtro,
      body: MeuApp.ehEstudante() ?
        MapaEstudante() :
        GoogleMap(
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
    mapaCarregou = true;
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
    if(!mapaCarregou || !temUsuario){
      print("Aguardando condições pra botar o marcador");
      return;
    }

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

class _FiltroDrawer extends StatefulWidget {
  @override
  _FiltroState createState() => _FiltroState();
}

class _FiltroState extends State<_FiltroDrawer>  {
  bool favoritos = true;
  bool laboratorios = true;
  bool escolas = true;
  bool incubadoras = false;
  //TODO Botar isso repetido no mapa, passar o mapa pra cá numa var Parent,
  //e setar sempre o state de ambos os widgets pra atualizar lá e aqui. (4/1/19)

  _FiltroState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 180,
        child: Drawer(
          child: Container(
            color: Colors.transparent,
            child: ListView(
              children: <Widget>[
                Checkbox(
                  value: favoritos,
                  onChanged: checkFavoritos,
                ),
                Checkbox(
                  value: laboratorios,
                  onChanged: checkLabs,
                ),
                Checkbox(
                  value: escolas,
                  onChanged: checkEscolas,
                ),
                Checkbox(
                  value: incubadoras,
                  onChanged: checkIncubadoras,
                ),
              ],
            ),
          ),
        )
    );
  }

  checkFavoritos(bool novo){
    setState(() {
      favoritos = novo;
    });
  }

  checkLabs(bool novo){
    setState(() {
      laboratorios = novo;
    });
  }

  checkEscolas(bool novo){
    setState(() {
      escolas = novo;
    });
  }

  checkIncubadoras(bool novo){
    setState(() {
      incubadoras = novo;
    });
  }

}