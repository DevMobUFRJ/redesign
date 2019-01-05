import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/chat/chat_tela.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/tela_base.dart';
import 'package:url_launcher/url_launcher.dart';

class PerfilInstituicao extends StatefulWidget {
  final Instituicao instituicao;

  PerfilInstituicao(this.instituicao);

  @override
  _PerfilInstituicaoState createState() => _PerfilInstituicaoState(instituicao);
}

class _PerfilInstituicaoState extends State<PerfilInstituicao> {

  final Instituicao instituicao;
  List<int> imagemPerfil;

  _PerfilInstituicaoState(this.instituicao){
    if(imagemPerfil == null) {
      if (instituicao.reference.documentID != MeuApp.userId()) {
        FirebaseStorage.instance.ref()
            .child("perfil/" + instituicao.reference.documentID + ".jpg")
            .getData(36000).then(salvaFotoPerfil)
            .catchError((e) => debugPrint("Erro foto"));
      } else if (imagemPerfil == null) {
        imagemPerfil = MeuApp.imagemMemory;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: "Perfil",
      body: ListView(
        children: <Widget>[
          Corpo()
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

  Widget Corpo(){
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: imagemPerfil != null ?
                                  MemoryImage(imagemPerfil)
                                  : AssetImage("images/perfil_placeholder.png"),
                            )
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          child: Text(
                            instituicao.nome + "a jabsd hasiudh iuahd ihasidh iausdh iuahsd iuh iuasdh hihasdiu hausid huiasdhiu",
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
                        child: Icon(Icons.directions, size: 26, color: Tema.primaryColor,),
                        onTap: (){},
                      ),
                      IconButton(
                        icon: Icon(Icons.star_border, color: Tema.primaryColor,),
                        iconSize: 26,
                        onPressed: (){},
                      ),
                    ],
                  ),
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
          Padding(padding: EdgeInsets.only(top:15),child: Divider(color: Colors.black54,),),
          ExpansionTile(
            title: Text("Bolsistas",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 22
              )
            ,),
            children: <Widget>[
              Divider(color: Colors.black54,),
              Text("Oi"),
              Text("Ear"),
            ],
          ),
          Divider(color: Colors.black54,),
          ExpansionTile(
            title: Text("Professores",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 22
              )
            ,),
            children: <Widget>[
              Divider(color: Colors.black54,),
              Text("Oi"),
              Text("Ear"),
            ],
          ),
          Divider(color: Colors.black54,),
        ],
      ),
    );
  }

  Widget redesPessoais( IconData icon, String informacao){
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

  _launchURL(String url) async{
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  salvaFotoPerfil(List<int> foto){
    setState(() {
      this.imagemPerfil = foto;
    });
  }
}

