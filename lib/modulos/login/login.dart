
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/mapa/mapa_tela.dart';
import 'package:redesign/widgets/botao_padrao.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Tema.principal.primaryColorDark,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 50, bottom: 50),
              child: Image.asset(
                  'images/rede_logo.png',
                  fit: BoxFit.fitWidth,
                  width: 200,
              ),
            ),
            _LoginPage(),
          ],
        )
      )
    );
  }
}

class _LoginPage extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<_LoginPage> {

  bool mostrandoLogin = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return mostrandoLogin ?
    _LoginForm()
    :
    Row(
      children: [
        Expanded(
          child:
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: BotaoPadrao("Entrar", mostrarLogin, Tema.principal.primaryColor, Tema.cinzaClaro)
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: BotaoPadrao("Cadastrar-se", cadastro,
                              Tema.buttonDarkGrey, Tema.cinzaClaro),
                ),
              ],
            )
        )
      ]
    );
  }

  mostrarLogin(){
    setState(() {
      mostrandoLogin = true;
    });
  }

  cadastro(){
    //TODO
  }
}

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
        children: [
          Expanded(
              child:
              Column(
                children: [
                  Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text("Email")
                  ),
                  Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text("Senha")
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: BotaoPadrao("Entrar", entrar,
                        Tema.principal.primaryColor, Tema.cinzaClaro),
                  ),
                ],
              )
          )
        ]
    );
  }

  entrar(){
    //TODO
    Navigator.pushNamed(
        context,
        '/mapa'
    );
  }
}