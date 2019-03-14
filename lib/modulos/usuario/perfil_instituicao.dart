import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/fb_icon_icons.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/modulos/chat/chat_tela.dart';
import 'package:redesign/modulos/usuario/favorite.dart';
import 'package:redesign/modulos/usuario/institution.dart';
import 'package:redesign/modulos/usuario/perfil_pessoa.dart';
import 'package:redesign/modulos/usuario/user.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/dados_asincronos.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:redesign/services/helper.dart';

class PerfilInstituicao extends StatefulWidget {
  final Institution instituicao;

  PerfilInstituicao(this.instituicao);

  @override
  _PerfilInstituicaoState createState() => _PerfilInstituicaoState(instituicao);
}

class _PerfilInstituicaoState extends State<PerfilInstituicao> {
  final Institution instituicao;
  bool ehFavorito = false;

  _PerfilInstituicaoState(this.instituicao){
    MyApp.getUserReference().collection(Favorite.collectionName)
        .where("id", isEqualTo: instituicao.reference.documentID)
        .snapshots().first.then((QuerySnapshot favorito) {
      if (favorito.documents.length != 0) {
        setState(() {
          ehFavorito = true;
        });
      }
    });
  }

  bool ocupado = false;
  void alternaFavorito() {
    if(ocupado) return;
    ocupado = true;
    MyApp.getUserReference().collection(Favorite.collectionName)
        .where("id", isEqualTo: instituicao.reference.documentID)
        .snapshots().first.then((QuerySnapshot vazio){
      if(vazio.documents.length == 0) {
        MyApp.getUserReference().collection(Favorite.collectionName)
            .add((new Favorite(id: instituicao.reference.documentID,
            className: instituicao.runtimeType.toString()).toJson()))
            .then((v){
          setState(() {
            ehFavorito = true;
          });
          ocupado = false;
        }).catchError((e){});
      } else {
        vazio.documents.first.reference.delete().then((v){
          setState(() {
            ehFavorito = false;
          });
          ocupado = false;
        }).catchError((e){});
      }
    }).catchError((e){});
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Perfil",
      body: ListView(
        children: <Widget>[
          _corpo()
        ],
      ),
      fab: instituicao.reference.documentID != MyApp.userId() ?
      FloatingActionButton(
        child: Icon(Icons.chat_bubble),
        backgroundColor: Style.main.primaryColor,
        onPressed: () =>
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatTela(null, outroUsuario: instituicao,))
            ),
      ) : null,
    );
  }

  Widget _corpo(){
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Hero(
                  tag: instituicao.reference.documentID,
                  child: CircleAvatarAsync(instituicao.reference.documentID, radius: 30,)
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Text(
                      instituicao.name,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 20,
                        color: Style.primaryColor,
                        fontWeight: FontWeight.w500
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),
                GestureDetector(
                  child: Icon(
                    Icons.directions, size: 28,
                    color: instituicao.lat == 0 || instituicao.lng == 0 ?
                      Colors.black26 : Style.primaryColor,
                  ),
                  onTap: () async {
                    if(instituicao.lat == 0 || instituicao.lng == 0) return;

                    String urlAndroid = "geo:0,0?q=" +
                        Uri.encodeQueryComponent(instituicao.address
                            + " - " + instituicao.city);
                    String urlios = "http://maps.apple.com/?address=" +
                        Uri.encodeFull(instituicao.address
                            + " - " + instituicao.city);
                    if(await canLaunch(urlAndroid)){
                      launch(urlAndroid);
                    } else if(await canLaunch(urlios)){
                      launch(urlios);
                    }
                  },
                ),
                IconButton(
                  icon: ehFavorito ?
                    Icon(Icons.star, color: Style.primaryColor,)
                    : Icon(Icons.star_border, color: Style.primaryColor,),
                  iconSize: 28,
                  onPressed: () => alternaFavorito(),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 5, right: 5, top: 15),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                      child: redesPessoais(Icons.email, instituicao.email)
                  ),
                  onTap: () => _launchURL("mailto:" + instituicao.email + "?subject=Contato%20pelo%20REDEsign"),
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(top: 15),
                    child: instituicao.site.isEmpty ? null : redesPessoais( Icons.public, instituicao.site),
                  ),
                  onTap: instituicao.site.isEmpty ? null : () => _launchURL(instituicao.site),
                ),
                GestureDetector(
                  child: Container(
                      padding: EdgeInsets.only(top: 15),
                      child: instituicao.facebook.isEmpty ? null : redesPessoais(FbIcon.facebook_official, instituicao.facebook)
                  ),
                  onTap: instituicao.facebook.isEmpty ? null : () => _launchURL(instituicao.facebook),
                ), // email
                // facebook
              ],
            ),
          ),
          // Se o método retornar "", então esconde um divider e esconde a lista secundária
          Helper.getSecondaryOccupationTitle(instituicao.occupation) == "" ? Container() :
          Padding(padding: EdgeInsets.only(top:15),child: Divider(color: Colors.black54,),),
          Helper.getSecondaryOccupationTitle(instituicao.occupation) == "" ? Container() :
          ExpansionTile(
            title: Text(Helper.getSecondaryOccupationTitle(instituicao.occupation),
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 22
              )
              ,),
            children: <Widget>[
              Divider(color: Colors.black54,),
              _UsuariosLista(Helper.getSecondaryOccupationToInstitution(instituicao.occupation), instituicao.reference.documentID),
            ],
          ),
          Divider(color: Colors.black54,),
          ExpansionTile(
            title: Text(Helper.getPrimaryOccupationTitle(instituicao.occupation),
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 22
              )
              ,),
            children: <Widget>[
              Divider(color: Colors.black54,),
              _UsuariosLista(Helper.getOcupacaoPrimariaParaInstituicao(instituicao.occupation), instituicao.reference.documentID),
            ],
          ),
          Divider(color: Colors.black54,),
        ],
      ),
    );
  }

  Widget redesPessoais(IconData icon, String informacao) {
    return Row(
      children: <Widget>[
        Container(
          child: Icon(icon, color: Style.buttonBlue,),
        ),
        Container(
          padding: EdgeInsets.only(left: 15),
        ),
        Text(informacao, style: TextStyle(fontSize: 15,color: Colors.black54))
      ],
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}

class _UsuariosLista extends StatefulWidget {
  /// Título da ocupação das pessoas que deseja listar. Ex: Bolsista.
  final String ocupacao;
  /// ID da instituição onde buscamos pessoas com aquela ocupação.
  final String instituicaoId;

  _UsuariosLista(this.ocupacao, this.instituicaoId);

  @override
  _UsuariosListaState createState() => _UsuariosListaState(ocupacao, instituicaoId);
}

class _UsuariosListaState extends State<_UsuariosLista> {
  final String ocupacao;
  final String instituicaoId;

  _UsuariosListaState(this.ocupacao, this.instituicaoId);

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(User.collectionName)
          .where("ocupacao", isEqualTo: ocupacao)
          .where("instituicaoId", isEqualTo: instituicaoId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(
        children: snapshot.length == 0 ? [Text("Nenhum cadastrado")] : snapshot.map((data) => _buildListItem(context, data)).toList()
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final User usuario = User.fromMap(data.data, reference: data.reference);

    return ListTile(
      key: ValueKey(data.reference.documentID),
      title: Text(
        usuario.name,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        maxLines: 2,
        overflow: TextOverflow.clip,
      ),
      leading: Hero(
        tag: usuario.reference.documentID,
        child: CircleAvatarAsync(usuario.reference.documentID, clicavel: true)
      ),
      onTap: () =>
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PerfilPessoa(usuario),
            ),
          ),
    );
  }
}
