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
  bool mapaCarregou = false;
  bool temUsuario = false;

  //Filtros
  bool laboratorios = true;
  bool escolas = true;
  bool incubadoras = true;
  bool empreendedores = true;

  @override
  void initState() {
    super.initState();
    if(MeuApp.userId() == null) {
      _getCurrentUser();
    } else {
      temUsuario = true;
      posLogin();
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
    if(!MeuApp.ativo()){
      erroEncontrarUsuario(null);
      return;
    }
    // Finalmente pode fazer o que tem que fazer.
    setState((){
      temUsuario = true;
    });
    posLogin();
  }

  void erroEncontrarUsuario(e){
    MeuApp.logout(context);
  }

  void posLogin(){
    getInstituicoesColocaMarcadores();
    MeuApp.startup();
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
      endDrawer: MeuApp.ehEstudante() ? null : _FiltroDrawer(this),
      body: MeuApp.ehEstudante() ?
        MapaEstudante() :
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(-22.8544375, -43.2296038),
            zoom: 12.0,
          ),
          onMapCreated: _onMapCreated,
          myLocationEnabled: false,
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
    if(!mapaCarregou || !temUsuario){ //Aguardando condições pra botar o marcador
      return;
    }

    Stream<QuerySnapshot> query = Firestore.instance.collection(Usuario.collectionName)
        .where("tipo", isEqualTo: TipoUsuario.instituicao.index)
        .where("ativo", isEqualTo: 1)
        .snapshots();
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

  void onFiltroMudou(){
    for(int i = 0; i < instituicoes.length; i++){
      Instituicao instituicao = instituicoes[i];

      if (instituicao.ocupacao == Ocupacao.incubadora) {
        if(incubadoras){
          mapController.updateMarker(marcadores[i], MarkerOptions(visible: true));
        } else {
          mapController.updateMarker(marcadores[i], MarkerOptions(visible: false));
        }
      } else if (instituicao.ocupacao == Ocupacao.escola) {
        if(escolas){
          mapController.updateMarker(marcadores[i], MarkerOptions(visible: true));
        } else {
          mapController.updateMarker(marcadores[i], MarkerOptions(visible: false));
        }
      } else if (instituicao.ocupacao == Ocupacao.laboratorio && instituicao.email != Helper.emailLabdis) {
        if(laboratorios){
          mapController.updateMarker(marcadores[i], MarkerOptions(visible: true));
        } else {
          mapController.updateMarker(marcadores[i], MarkerOptions(visible: false));
        }
      } else if (instituicao.ocupacao == Ocupacao.empreendedor) {
        if(empreendedores){
          mapController.updateMarker(marcadores[i], MarkerOptions(visible: true));
        } else {
          mapController.updateMarker(marcadores[i], MarkerOptions(visible: false));
        }
      }
    }
  }
}

class _FiltroDrawer extends StatefulWidget {

  final _MapaTelaState parent;

  _FiltroDrawer(this.parent);

  @override
  _FiltroState createState() => _FiltroState();
}

class _FiltroState extends State<_FiltroDrawer>  {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
        ),
        child: Drawer(
          semanticLabel: "Filtro do Mapa",
          child: Container(
            color: Colors.transparent,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 14.0, top: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Text( "Filtro",
                          style: TextStyle(
                            color: Tema.primaryColor,
                            fontSize: 18.0,
                          ),
                        )
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: Tema.primaryColor,
                        ),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Checkbox(
                      value: widget.parent.laboratorios,
                      onChanged: checkLabs,
                      activeColor: Tema.primaryColor,
                    ),
                    Expanded(child: Text("Laboratórios",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                      ),
                    )),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: widget.parent.escolas,
                      onChanged: checkEscolas,
                      activeColor: Tema.primaryColor,
                    ),
                    Expanded(child: Text("Escolas",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                      ),
                    )),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: widget.parent.incubadoras,
                      onChanged: checkIncubadoras,
                      activeColor: Tema.primaryColor,
                    ),
                    Expanded(child: Text("Incubadoras",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                      ),
                    )),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: widget.parent.empreendedores,
                      onChanged: checkEmpreendedores,
                      activeColor: Tema.primaryColor,
                    ),
                    Expanded(child: Text("Empreendedores",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  checkEmpreendedores(bool novo){
    setState(() {
      widget.parent.empreendedores = novo;
    });
    widget.parent.onFiltroMudou();
  }

  checkLabs(bool novo){
    setState(() {
      widget.parent.laboratorios = novo;
    });
    widget.parent.onFiltroMudou();
  }

  checkEscolas(bool novo){
    setState(() {
      widget.parent.escolas = novo;
    });
    widget.parent.onFiltroMudou();
  }

  checkIncubadoras(bool novo){
    setState(() {
      widget.parent.incubadoras = novo;
    });
    widget.parent.onFiltroMudou();
  }

}