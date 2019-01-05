import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/chat/chat_tela.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/tela_base.dart';
import 'package:url_launcher/url_launcher.dart';

class PerfilPessoa extends StatefulWidget {
  final Usuario usuario;
  PerfilPessoa(this.usuario);
  @override
  _PerfilPessoaState createState() => _PerfilPessoaState(usuario);
}

class _PerfilPessoaState extends State<PerfilPessoa> {

  final Usuario usuario;
  List<int> imagemPerfil;

  _PerfilPessoaState(this.usuario){
    if(imagemPerfil == null) {
      if (usuario.reference.documentID != MeuApp.userId()) {
        FirebaseStorage.instance.ref()
            .child("perfil/" + usuario.reference.documentID + ".jpg")
            .getData(36000).then(salvaFotoPerfil)
            .catchError((e) => debugPrint("Erro foto"));
      } else {
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
      fab: usuario.reference.documentID != MeuApp.userId() ?
      FloatingActionButton(
        child: Icon(Icons.chat_bubble),
        backgroundColor: Tema.principal.primaryColor,
        onPressed: () =>
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatTela(null, outroUsuario: usuario,))
          ),
      ) : null,
    );
  }

  Widget Corpo (){
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 80.0,
                        height: 80.0,
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
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          usuario.nome,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 5),
                        child: Text(usuario.ocupacao,style: TextStyle(fontSize: 15),),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top:  15,left: 15,right: 15),
                  child: Text(
                    usuario.descricao.isEmpty ?  "Nenhuma descrição" : usuario.descricao,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ) // Descição
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top:15, bottom: 15),child: Divider(color: Colors.black54,),),
          Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    child: redesPessoais(Icons.email, usuario.email)
                  ),
                  onTap: () => _launchURL("mailto:" + usuario.email + "?subject=Contato%20pelo%20REDEsign"),
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(top: 15),
                    child: usuario.site.isEmpty ? null : redesPessoais( Icons.public, usuario.site),
                  ),
                  onTap: usuario.site.isEmpty ? null : () => _launchURL(usuario.site),
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(top: 15),
                    child: usuario.facebook.isEmpty ? null : redesPessoais(Icons.public, usuario.facebook)
                  ),
                  onTap: usuario.facebook.isEmpty ? null : () => _launchURL(usuario.facebook),
                ), // email
                // facebook
              ],
            ),
          )
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

