import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:redesign/estilos/fb_icon_icons.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/modulos/chat/chat_tela.dart';
import 'package:redesign/modulos/usuario/user.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/dados_asincronos.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PerfilPessoa extends StatefulWidget {
  final User usuario;

  PerfilPessoa(this.usuario);

  @override
  _PerfilPessoaState createState() => _PerfilPessoaState(usuario);
}

class _PerfilPessoaState extends State<PerfilPessoa> {
  final User usuario;

  _PerfilPessoaState(this.usuario);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Perfil",
      body: ListView(
        children: <Widget>[
          _corpo()
        ],
      ),
      fab: usuario.reference.documentID != MyApp.userId() && !MyApp.isStudent() ?
      FloatingActionButton(
        child: Icon(Icons.chat_bubble),
        backgroundColor: Style.main.primaryColor,
        onPressed: () =>
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatTela(null, outroUsuario: usuario,))
          ),
      ) : null,
    );
  }

  Widget _corpo (){
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
                      Hero(
                        tag: usuario.reference.documentID,
                        child: CircleAvatarAsync(
                          usuario.reference.documentID,
                          radius: 40.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          usuario.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 5),
                        child: Text(usuario.occupation,style: TextStyle(fontSize: 15),),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top:  15,left: 15,right: 15),
                  child: Text(
                    usuario.description.isEmpty ?  "Nenhuma descrição" : usuario.description,
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
                    child: usuario.facebook.isEmpty ? null : redesPessoais(FbIcon.facebook_official, usuario.facebook)
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
            child: Icon(icon, color: Style.buttonBlue,),
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
}

