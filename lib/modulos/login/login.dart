import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/cadastro/registroOpcoes.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/botao_padrao.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseUser mCurrentUser;
FirebaseAuth _auth;

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Center(
            child: Container(
                color: Tema.principal.primaryColorDark,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
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
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _getCurrentUser();
  }

  /// Tenta logar o usuário pegando do cache logo ao criar a tela
  _getCurrentUser () async {
    mCurrentUser = await _auth.currentUser();
    if(mCurrentUser != null){
      loginSucesso(mCurrentUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return mostrandoLogin ?
    _LoginForm() : Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: BotaoPadrao(
                    "Nome", mostrarLogin, Tema.principal.primaryColor,
                    Tema.cinzaClaro)
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: BotaoPadrao("Cadastrar-se", cadastro, Tema.buttonDarkGrey,
                  Tema.cinzaClaro),
            ),
          ],
        )
    );
  }

  /// Usuario já estava em cache, então vai pro mapa.
  void loginSucesso(FirebaseUser user){
    MeuApp.firebaseUser = user;
    Navigator.pushNamed(
        context,
        '/mapa'
    );
  }

  mostrarLogin() {
    setState(() {
      mostrandoLogin = true;
    });
  }

  cadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistroOpcoes()),
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {

  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: TextField(
              style: TextStyle(decorationColor: Colors.white),
              cursorColor: Tema.buttonBlue,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              controller: emailController,
            )
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: TextField(
              cursorColor: Tema.buttonBlue,
              decoration: InputDecoration(
                labelText: 'Senha',
              ),
              obscureText: true,
              controller: senhaController,
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: BotaoPadrao("Entrar", entrar,
                Tema.principal.primaryColor, Tema.cinzaClaro
            ),
          ),
        ],
      )
    );
  }

  /// Tenta logar o usuário pelo email e senha do formulário
  entrar() async{
    if(emailController.text == null || emailController.text == "" || senhaController.text == null || senhaController.text == ""){
      emailController.text = "george@hotmail.com";
      senhaController.text = "123456";
    }

    await _auth.signInWithEmailAndPassword(
        email: emailController.text, password: senhaController.text)
        .then(loginSucesso)
        .catchError((e) => print(e));
  }

  void loginSucesso(FirebaseUser user){
    MeuApp.firebaseUser = user;
    Navigator.pushNamed(
        context,
        '/mapa'
    );
  }
}
