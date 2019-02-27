import 'package:flutter/material.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/autorizacao/autorizacao.dart';
import 'package:redesign/modulos/chat/chat_lista.dart';
import 'package:redesign/modulos/forum/forum_tema_lista.dart';
import 'package:redesign/modulos/mapa/mapa_estudante.dart';
import 'package:redesign/modulos/material/material_lista.dart';
import 'package:redesign/modulos/rede/rede_tela.dart';
import 'package:redesign/modulos/eventos/eventos_lista.dart';
import 'package:redesign/modulos/sobre/sobre_tela.dart';
import 'package:redesign/modulos/usuario/perfil_form.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/servicos/meu_app.dart';

class DrawerScreen extends StatefulWidget {
  final int mensagensNaoLidas;

  DrawerScreen({this.mensagensNaoLidas=0});

  @override
  DrawerScreenState createState() => DrawerScreenState();
}

class DrawerScreenState extends State<DrawerScreen> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          DrawerHeader(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => MeuApp.irProprioPerfil(context),
                    child: Hero(
                      tag: MeuApp.userId(),
                      child: Container(
                        width: 90.0,
                        height: 90.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: MeuApp.imagemMemory == null ?
                                AssetImage("images/perfil_placeholder.png") :
                                MemoryImage(MeuApp.imagemMemory),
                          )
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width:160.0 ,
                    margin: EdgeInsets.all(10.0),
                    child: Column (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(MeuApp.nome(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                            maxLines: 1,
                          ),
                        ),
                        Text(MeuApp.ocupacao(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal, fontSize: 16.0),
                          maxLines: 1,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget> [
                              RoundIconButton(
                                icon: Icon(Icons.edit),
                                iconColor: Colors.white,
                                circleColor: Color(0xff00838f),
                                size: 40.0,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => PerfilForm())
                                  );
                                },
                              ),
                              MeuApp.ehEstudante() ? Container() :
                              MessageIconButton(
                                mensagensNaoLidas: widget.mensagensNaoLidas,
                                icon: Icon(Icons.chat_bubble),
                                iconColor: Colors.white,
                                circleColor: Color(0xff00838f),
                                size: 40.0,
                                onPressed:  () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ChatLista())
                                  );
                                }
                              ),
                              RoundIconButton(
                                icon: Icon(Icons.exit_to_app),
                                iconColor: Colors.white,
                                circleColor: Color(0xff00838f),
                                size: 40.0,
                                onPressed: () => logout(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
                color: Tema.darkBackground
            ),
          ),
          ListaDrawer(
            icon: Icons.explore,
            iconColor: Tema.primaryColor,
            text: 'Mapa',
            onPressed: () {
              Navigator.pop(context);
            }
          ),
          MeuApp.ocupacao() != Ocupacao.professor ? Container() : ListaDrawer(
            icon: Icons.explore,
            iconColor: Tema.primaryColor,
            text: 'Mapa do Pegada',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapaEstudante(context))
              );
            }
          ),
          ListaDrawer(
            icon: Icons.people,
            iconColor: Tema.primaryColor,
            text: 'Rede',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RedeTela())
              );
            }
          ),
          ListaDrawer(
            icon: Icons.forum,
            iconColor: Tema.primaryColor,
            text: 'Fórum',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForumTemaLista())
              );
            }
          ),
          ListaDrawer(
            icon: Icons.library_books,
            iconColor: Tema.primaryColor,
            text: 'Materiais',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MaterialLista())
                );
              }
          ),
          ListaDrawer(
            icon: Icons.event,
            iconColor: Tema.primaryColor,
            text: 'Eventos',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventosTela())
              );
            }
          ),
          MeuApp.ehLabDis() ?
          ListaDrawer(
            icon: Icons.assignment_ind,
            iconColor: Tema.primaryColor,
            text: 'Autorizar Usuários',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AutorizacaoTela())
              );
            }
          ) : Container(),
          Expanded(child: Container()),
          Container(
            // This align moves the children to the bottom
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  // This container holds all the children that will be aligned
                  // on the bottom and should not scroll with the above ListView
                  child: Container(
                      child: Column(
                        children: <Widget>[
                          Divider(color: Colors.black54, height: 0,),
                          ListaDrawer(
                            icon: Icons.help,
                            iconColor: Tema.primaryColor,
                            text: 'Sobre',
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SobreTela())
                              );
                            },
                          )
                        ],
                      )
                  )
              )
          ),
        ],
      ),
    );
  }

  logout(BuildContext context) {
    MeuApp.logout(context);
  }
}

class RoundIconButton extends StatelessWidget {
  final Icon icon;
  final Color iconColor;
  final Color circleColor;
  final double size;
  final VoidCallback onPressed;

  RoundIconButton({
    this.icon,
    this.iconColor,
    this.circleColor,
    this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: circleColor,
      ),
      child: IconButton(
        alignment: Alignment.center,
        icon: icon,
        color: iconColor,
        onPressed: onPressed,
      ),
    );
  }
}

class ListaDrawer extends StatelessWidget{
  final IconData icon;
  final Color iconColor;
  final String text;
  final VoidCallback onPressed;

  ListaDrawer({
    this.icon,
    this.iconColor,
    this.text,
    this.onPressed,
});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: iconColor,),
      title: Text(text,
        style: TextStyle(
          color: Colors.black45),
      ),
      onTap: onPressed,
    );
  }
}

class MessageIconButton extends StatelessWidget {
  final int mensagensNaoLidas;
  final Icon icon;
  final Color iconColor;
  final Color circleColor;
  final double size;
  final VoidCallback onPressed;

  MessageIconButton({
    this.icon,
    this.iconColor,
    this.circleColor,
    this.size,
    this.onPressed,
    @required this.mensagensNaoLidas,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
            ),
            child: IconButton(
              alignment: Alignment.center,
              icon: icon,
              color: iconColor,
              onPressed: onPressed,
            ),
          ),
        ),
        mensagensNaoLidas == 0 ? Container() : CircleAvatar(
          radius: 10,
          backgroundColor: Colors.red,
          child: Text(mensagensNaoLidas.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}