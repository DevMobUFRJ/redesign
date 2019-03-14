import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/modulos/chat/chat.dart';
import 'package:redesign/modulos/chat/mensagem.dart';
import 'package:redesign/modulos/map/drawer_screen.dart';
import 'package:redesign/modulos/map/map_student.dart';
import 'package:redesign/modulos/usuario/institution.dart';
import 'package:redesign/modulos/usuario/perfil_instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_pessoa.dart';
import 'package:redesign/modulos/usuario/user.dart';
import 'package:redesign/services/helper.dart';
import 'package:redesign/services/my_app.dart';

FirebaseUser mCurrentUser;

class MapScreen extends StatefulWidget {
  MapScreen({Key key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;
  List<Marker> markers = [];
  List<Institution> institutions = [];
  bool mapLoaded = false;
  bool hasUser = false;
  int unreadMessages = 1;
  List<String> unread = [];

  //Filtros
  bool labs = true;
  bool schools = true;
  bool incubators = true;
  bool entrepreneurs = true; //empreendedor

  @override
  void initState() {
    super.initState();
    if(MyApp.userId() == null) {
      _getCurrentUser();
    } else {
      hasUser = true;
      posLogin();
    }
  }

  /// Tenta logar o usuário pegando do cache logo ao criar a tela
  _getCurrentUser() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser _currentUser = await _auth.currentUser();
    if(_currentUser != null){
      authSuccess(_currentUser);
    } else {
      findUserError(null);
    }
  }

  /// Usuario já estava em cache, então vai pro mapa.
  void authSuccess(FirebaseUser user){
    mCurrentUser = user;
    MyApp.firebaseUser = user;
    Firestore.instance.collection(User.collectionName).document(user.uid).get()
        .then(didFindUser).catchError(findUserError);
  }

  void didFindUser(DocumentSnapshot snapshot){
    if(snapshot.data['tipo'] == UserType.institution.index){
      MyApp.setUser(Institution.fromMap(snapshot.data, reference: snapshot.reference));
    } else {
      MyApp.setUser(User.fromMap(snapshot.data, reference: snapshot.reference));
    }
    if(!MyApp.active()){
      findUserError(null);
      return;
    }
    // Finalmente pode fazer o que tem que fazer.
    setState((){
      hasUser = true;
    });
    posLogin();
  }

  void findUserError(e){
    MyApp.logout(context);
  }

  void posLogin(){
    getInstitutionsPutMarker();
    MyApp.startup();
    countUnreadMessages();
  }

  @override
  Widget build(BuildContext context) {
    if(!hasUser){
      return Scaffold(
        body: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Style.darkBackground,
                child: Center(
                  child: CircularProgressIndicator(),
                ),),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: DrawerScreen(mensagensNaoLidas: unreadMessages,),
      appBar: AppBar(
        title: Text("REDEsign"),
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        actions: MyApp.isStudent() ? null : [
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
      endDrawer: MyApp.isStudent() ? null : _drawerFilter(this),
      body: MyApp.isStudent() ?
        MapStudent(context) :
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
    mapLoaded = true;
    mapController.onInfoWindowTapped.add(_infoTapped);
    getInstitutionsPutMarker();
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
    Institution institution = institutions[markers.indexOf(marker)];
    Navigator.push(
        context,
        MaterialPageRoute(builder:(context) =>
          // Apesar de empreendedores serem do tipo Instituição p/ ter lat-lng,
          // a visualização é de pessoa.
          institution.occupation != Occupation.empreendedor ?
            PerfilInstituicao(institution)
            : PerfilPessoa(institution)),
    );
  }

  getInstitutionsPutMarker(){
    if(!mapLoaded || !hasUser){ //Aguardando condições pra botar o marcador
      return;
    }

    Stream<QuerySnapshot> query = Firestore.instance.collection(User.collectionName)
        .where("tipo", isEqualTo: UserType.institution.index)
        .where("ativo", isEqualTo: 1)
        .snapshots();
    query.forEach((element){
      for(DocumentSnapshot d in element.documents){
        Institution institution = Institution.fromMap(d.data, reference: d.reference);

        if(institution.lat == 0 || institution.lng == 0) continue;

        String icon = "";
        if(institution.email == Helper.emailLabdis){
          icon = "labdis";
        } else if (institution.occupation == Occupation.incubadora) {
          icon = "incubadora";
        } else if (institution.occupation == Occupation.escola) {
          icon = "escola";
        } else if (institution.occupation == Occupation.laboratorio) {
          icon = "laboratorio";
        } else if (institution.occupation == Occupation.empreendedor) {
          icon = "empreendedor";
        }

        LatLng center = LatLng(institution.lat, institution.lng);
        mapController.addMarker(
          MarkerOptions(
            position: center,
            infoWindowText: InfoWindowText(institution.name, "Detalhes"),
            icon: BitmapDescriptor.fromAsset("images/icones/ic_" + icon + ".png"),
        )).then((marker) {
          markers.add(marker);
          institutions.add(institution);
        });
      }
    });
  }

  void onFilterChanged(){
    for(int i = 0; i < institutions.length; i++){
      Institution institution = institutions[i];

      if (institution.occupation == Occupation.incubadora) {
        if(incubators){
          mapController.updateMarker(markers[i], MarkerOptions(visible: true));
        } else {
          mapController.updateMarker(markers[i], MarkerOptions(visible: false));
        }
      } else if (institution.occupation == Occupation.escola) {
        if(schools){
          mapController.updateMarker(markers[i], MarkerOptions(visible: true));
        } else {
          mapController.updateMarker(markers[i], MarkerOptions(visible: false));
        }
      } else if (institution.occupation == Occupation.laboratorio && institution.email != Helper.emailLabdis) {
        if(labs){
          mapController.updateMarker(markers[i], MarkerOptions(visible: true));
        } else {
          mapController.updateMarker(markers[i], MarkerOptions(visible: false));
        }
      } else if (institution.occupation == Occupation.empreendedor) {
        if(entrepreneurs){
          mapController.updateMarker(markers[i], MarkerOptions(visible: true));
        } else {
          mapController.updateMarker(markers[i], MarkerOptions(visible: false));
        }
      }
    }
  }

  void countUnreadMessages(){
    unreadMessages = 0;
    getData().first.then((snaps) => snaps.forEach((query){
        query.documents.forEach((doc){
          doc.reference.collection(Mensagem.collectionName)
              .where("lida", isEqualTo: false).snapshots()
              .forEach((queryMsg){
             if(queryMsg.documents.length < 0) return;

             queryMsg.documents.forEach((msg){
               if(msg.data['criadaPor'] != MyApp.userId()){
                 // Previne adição repetida
                 if(unread.contains(doc.reference.documentID)) return;
                 unread.add(doc.reference.documentID);
                 setState(() {
                   unreadMessages++;
                 });
                 print(msg.data);
                 return;
               }
             });
          });
        });
      })
    );
  }

  Stream<List<QuerySnapshot>> getData() {
    Stream stream1 = Firestore.instance.collection(Chat.collectionName)
        .where('user1', isEqualTo: MyApp.userId()).snapshots();
    Stream stream2 = Firestore.instance.collection(Chat.collectionName)
        .where('user2', isEqualTo: MyApp.userId()).snapshots();
    return StreamZip([stream1, stream2]);
  }
}

class _drawerFilter extends StatefulWidget {

  final _MapScreenState parent;

  _drawerFilter(this.parent);

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<_drawerFilter>  {
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
                            color: Style.primaryColor,
                            fontSize: 18.0,
                          ),
                        )
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: Style.primaryColor,
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
                      value: widget.parent.labs,
                      onChanged: checkLabs,
                      activeColor: Style.primaryColor,
                    ),
                    Expanded(child: GestureDetector(
                      child: Text("Laboratórios",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16.0,
                        ),
                      ),
                      onTap: toggleLabs,
                    )),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: widget.parent.schools,
                      onChanged: checkSchools,
                      activeColor: Style.primaryColor,
                    ),
                    Expanded(child: GestureDetector(
                      child: Text("Escolas",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16.0,
                        ),
                      ),
                      onTap: toggleSchools,
                    )),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: widget.parent.incubators,
                      onChanged: checkIncubators,
                      activeColor: Style.primaryColor,
                    ),
                    Expanded(child: GestureDetector(
                      child: Text("Incubadoras",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16.0,
                        ),
                      ),
                      onTap: toggleIncubators,
                    )),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: widget.parent.entrepreneurs,
                      onChanged: checkEntrepreneurs,
                      activeColor: Style.primaryColor,
                    ),
                    Expanded(child: GestureDetector(
                      child: Text("Empreendedores",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16.0,
                        ),
                      ),
                      onTap: toggleEntrepreneurs,
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

  checkEntrepreneurs(bool newEntrepreneurs){
    setState(() {
      widget.parent.entrepreneurs = newEntrepreneurs;
    });
    widget.parent.onFilterChanged();
  }

  toggleEntrepreneurs(){
    setState(() {
      widget.parent.entrepreneurs = !widget.parent.entrepreneurs;
    });
    widget.parent.onFilterChanged();
  }

  checkLabs(bool newEntrepreneur){
    setState(() {
      widget.parent.labs = newEntrepreneur;
    });
    widget.parent.onFilterChanged();
  }

  toggleLabs(){
    setState(() {
      widget.parent.labs = !widget.parent.labs;
    });
    widget.parent.onFilterChanged();
  }

  checkSchools(bool newSchool){
    setState(() {
      widget.parent.schools = newSchool;
    });
    widget.parent.onFilterChanged();
  }

  toggleSchools(){
    setState(() {
      widget.parent.schools = !widget.parent.schools;
    });
    widget.parent.onFilterChanged();
  }

  checkIncubators(bool newIncubator){
    setState(() {
      widget.parent.incubators = newIncubator;
    });
    widget.parent.onFilterChanged();
  }

  toggleIncubators(){
    setState(() {
      widget.parent.incubators = !widget.parent.incubators;
    });
    widget.parent.onFilterChanged();
  }
}