import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/modulos/usuario/favorite.dart';
import 'package:redesign/modulos/usuario/institution.dart';
import 'package:redesign/modulos/usuario/perfil_instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_pessoa.dart';
import 'package:redesign/modulos/usuario/user.dart';
import 'package:redesign/services/helper.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/item_lista_simples.dart';
import 'package:redesign/widgets/base_screen.dart';

class RedeLista extends StatefulWidget {
  final String ocupacao;

  RedeLista(this.ocupacao, {Key key}) : super(key: key);

  @override
  RedeListaState createState() => RedeListaState(ocupacao);
}

class RedeListaState extends State<RedeLista> {
  bool searching = false;
  TextEditingController _searchController = TextEditingController();
  String search = "";

  final String occupation;

  RedeListaState(this.occupation);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: occupation,
        body: occupation == "Favoritos" ?
          _buildFavoritos(context)
          : _buildBody(context),
        actions: <IconButton>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white
            ),
            onPressed: () => toggleSearch(),
          ),
        ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(User.collectionName)
          .where("ocupacao", isEqualTo: this.occupation)
          .where("ativo", isEqualTo: 1)
          .orderBy("nome")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        if(snapshot.data.documents.length == 0)
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Não há usuários nessa categoria"),
            ],
          );

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(
        children: [
          Expanded(
            child:  ListView(
              children: [
                searching ?
                Container(
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: ShapeDecoration(shape: StadiumBorder() ),
                    child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: textoBuscaMudou,
                              controller: _searchController,
                              cursorColor: Style.lightGrey,
                              decoration: InputDecoration(
                                  hintText: "Buscar",
                                  prefixIcon: Icon(Icons.search, color: Style.primaryColor)
                              ),
                            ),
                          ),
                        ]
                    )
                )
                    : Container(),
              ]
              ..addAll(snapshot.map((data) => _buildListItem(context, data)).toList()),
            ),
          ),
        ]
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    User usuario;
    Institution instituicao;

    if(data.data['tipo'] == UserType.person.index) {
      usuario = User.fromMap(data.data, reference: data.reference);
      if(!usuario.name.toLowerCase().contains(search)
          && !usuario.description.toLowerCase().contains(search))
        return Container();
    } else {
      instituicao = Institution.fromMap(data.data, reference: data.reference);
      if(!instituicao.name.toLowerCase().contains(search)
          && !instituicao.description.toLowerCase().contains(search))
        return Container();
    }

    return ItemListaSimples(
      usuario != null ? usuario.name : instituicao.name,
      usuario != null ? () => callbackUsuario(context, usuario) :
                        () => callbackInstituicao(context, instituicao),
      corTexto: Style.darkText,
      key: ValueKey(data.documentID),
    );
  }

  Widget _buildFavoritos(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: MyApp.getUserReference().collection(Favorite.collectionName)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        if(snapshot.data.documents.length == 0)
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Você ainda não salvou favoritos"),
            ],
          );

        return _buildFavoritosList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildFavoritosList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(
        children: [
          Expanded(
            child:  ListView(
              children: [
                searching ?
                Container(
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: ShapeDecoration(shape: StadiumBorder() ),
                    child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: textoBuscaMudou,
                              controller: _searchController,
                              cursorColor: Style.lightGrey,
                              decoration: InputDecoration(
                                  hintText: "Buscar",
                                  prefixIcon: Icon(Icons.search, color: Style.primaryColor)
                              ),
                            ),
                          ),
                        ]
                    )
                )
                    : Container(),
              ]
                ..addAll(snapshot
                    .where((snap) =>
                        snap.data['classe'] == 'Instituicao'
                        || snap.data['classe'] == 'Usuario')
                    .map((data) => _FavoritoItem(data['id'])).toList()),
            ),
          ),
        ]
    );
  }

  toggleSearch(){
    setState((){
      searching = !searching;
    });
    if(!searching) {
      _searchController.text = "";
      textoBuscaMudou("");
    }
  }

  textoBuscaMudou(String texto){
    setState(() {
      search = texto.toLowerCase();
    });
  }
}

class _FavoritoItem extends StatefulWidget {
  final String userId;

  _FavoritoItem(this.userId) : super(key: Key(userId));

  @override
  _FavoritoItemState createState() => _FavoritoItemState();
}

class _FavoritoItemState extends State<_FavoritoItem> {
  User usuario;
  Institution instituicao;

  @override
  void initState() {
    super.initState();
    Firestore.instance.collection(User.collectionName)
        .document(widget.userId).get().then((DocumentSnapshot snapshot){
          setState(() {
            if(snapshot.data['tipo'] == UserType.institution.index){
              instituicao = Institution.fromMap(snapshot.data, reference: snapshot.reference);
            } else {
              usuario = User.fromMap(snapshot.data, reference: snapshot.reference);
            }
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    if(usuario == null && instituicao == null){
      return Container();
    }

    Widget icone;
    if(instituicao != null){
      if(instituicao.email == Helper.emailLabdis){
        icone = Image.asset("images/icones/ic_labdis.png", height: 35.0,);
      } else if(instituicao.occupation == Occupation.laboratorio){
        icone = Image.asset("images/icones/ic_laboratorio.png", height: 35.0,);
      } else if(instituicao.occupation == Occupation.escola){
        icone = Image.asset("images/icones/ic_escola.png", height: 35.0,);
      } else if(instituicao.occupation == Occupation.incubadora){
        icone = Image.asset("images/icones/ic_incubadora.png", height: 35.0,);
      } else if(instituicao.occupation == Occupation.empreendedor){
        icone = Image.asset("images/icones/ic_empreendedor.png", height: 35.0,);
      }
    }

    return ItemListaSimples(
      usuario != null ? usuario.name : instituicao.name,
      usuario != null ? () => callbackUsuario(context, usuario) :
          () => callbackInstituicao(context, instituicao),
      corTexto: Style.darkText,
      iconeExtra: icone,
    );
  }
}

void callbackUsuario(BuildContext context, User usuario){
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PerfilPessoa(usuario),
    ),
  );
}

void callbackInstituicao(BuildContext context, Institution instituicao){
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PerfilInstituicao(instituicao),
    ),
  );
}