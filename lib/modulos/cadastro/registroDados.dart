import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/botao_padrao.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/estilos/tema.dart';

Usuario usuario = new Usuario();
FirebaseAuth _auth = FirebaseAuth.instance;

class RegistroDados extends StatelessWidget {

  String ocupacao ;
  TipoUsuario tipo;

  RegistroDados({ this.ocupacao, this.tipo });

  @override
  Widget build(BuildContext context) {

    usuario.ocupacao = ocupacao;
    usuario.tipo = tipo;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 15, 34, 38),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
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
  return Container(
    alignment: Alignment.center,
    height: 250,
    width: 250,
    padding: EdgeInsets.only(top: 50, bottom: 20),
    child: Image.asset(
      'images/rede_logo.png',
      fit: BoxFit.contain,
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

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

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
                  labelText: 'Nome',),
                controller: _nomeController,
              )
          ),Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: TextFormField(
                style: TextStyle(
                    decorationColor: Colors.white
                ),
                //cursorColor: Tema.buttonBlue,
                decoration: InputDecoration(
                  labelText: 'E-mail',),
              controller: _emailController,)
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
      if(_nomeController.text.isNotEmpty && _emailController.text.isNotEmpty){
        usuario.email = _emailController.text.trim();
        usuario.nome = _nomeController.text.trim();
        registroSenha = true;
      }
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

  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _senhaConfirmaController = TextEditingController();

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
                obscureText: true,
                controller: _senhaController,)
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TextField(
                  cursorColor: Tema.buttonBlue,
                  decoration: InputDecoration(
                    labelText: 'Confirme a senha',
                  ),
                  obscureText: true,
                controller: _senhaConfirmaController,)
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: BotaoPadrao("Confirmar", criaUsuario,
                  Tema.principal.primaryColor, Tema.cinzaClaro),
            ),
          ],
        )
    );
  }

  criaUsuario(){
    if(_senhaConfirmaController.text.isNotEmpty && _senhaController.text.isNotEmpty
        && _senhaController.text == _senhaConfirmaController.text){
      _auth.createUserWithEmailAndPassword(
          email: usuario.email,
          password: _senhaController.text).then(adicionaBanco).catchError((e)=> print(e));
    }
  }

  adicionaBanco(FirebaseUser user){
    Firestore.instance.collection(Usuario.collectionName).document(user.uid).setData(usuario.toJson()).then(entrar).catchError((e)=> print(e)) ;
    MeuApp.firebaseUser = user;
    usuario.reference = Firestore.instance.collection(Usuario.collectionName).document(user.uid);
  }

  entrar(dynamic) {
    MeuApp.usuario = usuario;
      Navigator.pushNamed(
          context,
        '/mapa'
      );
    }
}