import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/chat/chat_tela.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_pessoa.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/dados_asincronos.dart';
import 'package:redesign/widgets/tela_base.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:redesign/servicos/helper.dart';

class PerfilInstituicao extends StatefulWidget {
  final Instituicao instituicao;

  PerfilInstituicao(this.instituicao);

  @override
  _PerfilInstituicaoState createState() => _PerfilInstituicaoState(instituicao);
}

class _PerfilInstituicaoState extends State<PerfilInstituicao> {
  final Instituicao instituicao;

  _PerfilInstituicaoState(this.instituicao);

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: "Perfil",
      body: ListView(
        children: <Widget>[
          _corpo()
        ],
      ),
      fab: instituicao.reference.documentID != MeuApp.userId() ?
      FloatingActionButton(
        child: Icon(Icons.chat_bubble),
        backgroundColor: Tema.principal.primaryColor,
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
                CircleAvatarAsync(instituicao.reference.documentID, radius: 30,),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Text(
                      instituicao.nome,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 20,
                        color: Tema.primaryColor,
                        fontWeight: FontWeight.w500
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),
                GestureDetector(
                  child: Icon(
                    Icons.directions, size: 26,
                    color: instituicao.lat == 0 || instituicao.lng == 0 ?
                      Colors.black26 : Tema.primaryColor,
                  ),
                  onTap: () async {
                    if(instituicao.lat == 0 || instituicao.lng == 0) return;

                    String urlAndroid = "geo:0,0?q=" +
                        Uri.encodeQueryComponent(instituicao.endereco
                            + " - " + instituicao.cidade);
                    String urlios = "http://maps.apple.com/?address=" +
                        Uri.encodeFull(instituicao.endereco
                            + " - " + instituicao.cidade);
                    if(await canLaunch(urlAndroid)){
                      launch(urlAndroid);
                    } else if(await canLaunch(urlios)){
                      launch(urlios);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.star_border, color: Tema.primaryColor,),
                  iconSize: 26,
                  onPressed: (){},
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
                      child: instituicao.facebook.isEmpty ? null : redesPessoais(Icons.public, instituicao.facebook)
                  ),
                  onTap: instituicao.facebook.isEmpty ? null : () => _launchURL(instituicao.facebook),
                ), // email
                // facebook
              ],
            ),
          ),
          // Se o método retornar "", então esconde um divider e esconde a lista secundária
          Helper.getTituloOcupacaoSecundaria(instituicao.ocupacao) == "" ? Container() :
          Padding(padding: EdgeInsets.only(top:15),child: Divider(color: Colors.black54,),),
          Helper.getTituloOcupacaoSecundaria(instituicao.ocupacao) == "" ? Container() :
          ExpansionTile(
            title: Text(Helper.getTituloOcupacaoSecundaria(instituicao.ocupacao),
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 22
              )
              ,),
            children: <Widget>[
              Divider(color: Colors.black54,),
              _UsuariosLista(Helper.getOcupacaoSecundariaParaInstituicao(instituicao.ocupacao), instituicao.reference.documentID),
            ],
          ),
          Divider(color: Colors.black54,),
          ExpansionTile(
            title: Text(Helper.getTituloOcupacaoPrimaria(instituicao.ocupacao),
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 22
              )
              ,),
            children: <Widget>[
              Divider(color: Colors.black54,),
              _UsuariosLista(Helper.getOcupacaoPrimariaParaInstituicao(instituicao.ocupacao), instituicao.reference.documentID),
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
          child: Icon(icon, color: Tema.buttonBlue,),
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
      stream: Firestore.instance.collection(Usuario.collectionName)
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
    final Usuario usuario = Usuario.fromMap(data.data, reference: data.reference);

    return ListTile(
      key: ValueKey(data.reference.documentID),
      title: Text(
        usuario.nome,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        maxLines: 2,
        overflow: TextOverflow.clip,
      ),
      leading: CircleAvatarAsync(usuario.reference.documentID),
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
