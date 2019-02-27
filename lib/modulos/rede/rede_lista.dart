import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/usuario/favorito.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_pessoa.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/servicos/helper.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/item_lista_simples.dart';
import 'package:redesign/widgets/tela_base.dart';

class RedeLista extends StatefulWidget {
  final String ocupacao;

  RedeLista(this.ocupacao, {Key key}) : super(key: key);

  @override
  RedeListaState createState() => RedeListaState(ocupacao);
}

class RedeListaState extends State<RedeLista> {
  bool buscando = false;
  TextEditingController _buscaController = TextEditingController();
  String busca = "";

  final String ocupacao;

  RedeListaState(this.ocupacao);

  @override
  Widget build(BuildContext context) {
    return TelaBase(
        title: ocupacao,
        body: ocupacao == "Favoritos" ?
          _buildFavoritos(context)
          : _buildBody(context),
        actions: <IconButton>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white
            ),
            onPressed: () => alternarBusca(),
          ),
        ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(Usuario.collectionName)
          .where("ocupacao", isEqualTo: this.ocupacao)
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
                buscando ?
                Container(
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: ShapeDecoration(shape: StadiumBorder() ),
                    child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: textoBuscaMudou,
                              controller: _buscaController,
                              cursorColor: Tema.cinzaClaro,
                              decoration: InputDecoration(
                                  hintText: "Buscar",
                                  prefixIcon: Icon(Icons.search, color: Tema.primaryColor)
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
    Usuario usuario;
    Instituicao instituicao;

    if(data.data['tipo'] == TipoUsuario.pessoa.index) {
      usuario = Usuario.fromMap(data.data, reference: data.reference);
      if(!usuario.nome.toLowerCase().contains(busca)
          && !usuario.descricao.toLowerCase().contains(busca))
        return Container();
    } else {
      instituicao = Instituicao.fromMap(data.data, reference: data.reference);
      if(!instituicao.nome.toLowerCase().contains(busca)
          && !instituicao.descricao.toLowerCase().contains(busca))
        return Container();
    }

    return ItemListaSimples(
      usuario != null ? usuario.nome : instituicao.nome,
      usuario != null ? () => callbackUsuario(context, usuario) :
                        () => callbackInstituicao(context, instituicao),
      corTexto: Tema.textoEscuro,
      key: ValueKey(data.documentID),
    );
  }

  Widget _buildFavoritos(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: MeuApp.getReferenciaUsuario().collection(Favorito.collectionName)
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
                buscando ?
                Container(
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: ShapeDecoration(shape: StadiumBorder() ),
                    child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: textoBuscaMudou,
                              controller: _buscaController,
                              cursorColor: Tema.cinzaClaro,
                              decoration: InputDecoration(
                                  hintText: "Buscar",
                                  prefixIcon: Icon(Icons.search, color: Tema.primaryColor)
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

  alternarBusca(){
    setState((){
      buscando = !buscando;
    });
    if(!buscando) {
      _buscaController.text = "";
      textoBuscaMudou("");
    }
  }

  textoBuscaMudou(String texto){
    setState(() {
      busca = texto.toLowerCase();
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
  Usuario usuario;
  Instituicao instituicao;

  @override
  void initState() {
    super.initState();
    Firestore.instance.collection(Usuario.collectionName)
        .document(widget.userId).get().then((DocumentSnapshot snapshot){
          setState(() {
            if(snapshot.data['tipo'] == TipoUsuario.instituicao.index){
              instituicao = Instituicao.fromMap(snapshot.data, reference: snapshot.reference);
            } else {
              usuario = Usuario.fromMap(snapshot.data, reference: snapshot.reference);
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
      } else if(instituicao.ocupacao == Ocupacao.laboratorio){
        icone = Image.asset("images/icones/ic_laboratorio.png", height: 35.0,);
      } else if(instituicao.ocupacao == Ocupacao.escola){
        icone = Image.asset("images/icones/ic_escola.png", height: 35.0,);
      } else if(instituicao.ocupacao == Ocupacao.incubadora){
        icone = Image.asset("images/icones/ic_incubadora.png", height: 35.0,);
      } else if(instituicao.ocupacao == Ocupacao.empreendedor){
        icone = Image.asset("images/icones/ic_empreendedor.png", height: 35.0,);
      }
    }

    return ItemListaSimples(
      usuario != null ? usuario.nome : instituicao.nome,
      usuario != null ? () => callbackUsuario(context, usuario) :
          () => callbackInstituicao(context, instituicao),
      corTexto: Tema.textoEscuro,
      iconeExtra: icone,
    );
  }
}

void callbackUsuario(BuildContext context, Usuario usuario){
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PerfilPessoa(usuario),
    ),
  );
}

void callbackInstituicao(BuildContext context, Instituicao instituicao){
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PerfilInstituicao(instituicao),
    ),
  );
}