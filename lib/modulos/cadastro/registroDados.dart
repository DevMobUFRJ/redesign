import 'package:flutter/material.dart';
import 'package:redesign/widgets/botao_padrao.dart';
import 'package:redesign/estilos/tema.dart';

class RegistroDados extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 15, 34, 38),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Logo(),
            _RegisterForm()
          ],
        ),
      ),
    );
  }
}

Widget Logo() {
  return Padding(
    padding: EdgeInsets.only(top: 50, bottom: 20),
    child: Image.asset(
      'images/rede_logo.png',
      fit: BoxFit.fitWidth,
      width: 200,
    ),
  );
}

class _RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {

  bool registroSenha = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return registroSenha ?
    _SenhaForm() : Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: TextField(style: TextStyle(decorationColor: Colors.white),
                cursorColor: Tema.buttonBlue,
                decoration: InputDecoration(
                  labelText: 'Nome',),)
          ),Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: TextField(style: TextStyle(decorationColor: Colors.white),
                cursorColor: Tema.buttonBlue,
                decoration: InputDecoration(
                  labelText: 'E-mail',),)
          ),
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: BotaoPadrao(
                    "Próximo", mostrarSenha, Tema.principal.primaryColor,
                    Tema.cinzaClaro)
            ),
          ],
        )
    );
  }

  mostrarSenha() {
    setState(() {
      registroSenha = true;
    });
  }

  entrar() {
    //TODO
    Navigator.pushNamed(
        context,
        '/mapa'
    );
  }
}

class _SenhaForm extends StatefulWidget {
  @override
  _SenhaFormState createState() => _SenhaFormState();
}

class _SenhaFormState extends State<_SenhaForm> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TextField(style: TextStyle(decorationColor: Colors.white),
                  cursorColor: Tema.buttonBlue,
                  decoration: InputDecoration(
                    labelText: 'Escolha uma senha',),
                obscureText: true,)
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TextField(
                  cursorColor: Tema.buttonBlue,
                  decoration: InputDecoration(
                    labelText: 'Confirme a senha',
                  ),
                  obscureText: true,)
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: BotaoPadrao("Confirmar", entrar,
                  Tema.principal.primaryColor, Tema.cinzaClaro),
            ),
          ],
        )
    );
  }

  entrar() {
    //TODO
    Navigator.pushNamed(
        context,
        '/mapa'
    );
  }
}