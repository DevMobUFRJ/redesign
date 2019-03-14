import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:redesign/modulos/usuario/institution.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/services/validators.dart';
import 'package:redesign/widgets/standard_button.dart';
import 'package:redesign/modulos/usuario/user.dart';
import 'package:redesign/estilos/style.dart';

User _usuario;
FirebaseAuth _auth = FirebaseAuth.instance;
GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class RegistroDados extends StatelessWidget {

  String ocupacao ;
  UserType tipo;

  RegistroDados({ this.ocupacao, this.tipo }){
    if(_usuario == null) {
      if (tipo == UserType.person) {
        _usuario = User();
      } else {
        _usuario = Institution();
      }
      _usuario.occupation = ocupacao;
      _usuario.type = tipo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color.fromARGB(255, 15, 34, 38),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ListView(
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
    return registroSenha ?
    _SenhaForm() : Container(
        padding: EdgeInsets.only(top: 15.0),
        child: Column(
          children: [Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: TextField(
                style: TextStyle(
                    decorationColor: Style.lightGrey,
                    color: Colors.white
                ),
                cursorColor: Style.buttonBlue,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white54
                    ),
                  ),
                ),
                controller: _nomeController,
              )
          ),Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: TextFormField(
              style: TextStyle(
                decorationColor: Style.lightGrey,
                color: Colors.white
              ),
              decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white54
                  ),
                ),
              ),
              controller: _emailController,
              autovalidate: true,
              validator: (val) => Validators.email(val) ? null : 'Email inválido',
            )
          ),
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: StandardButton(
                    "Próximo", mostrarSenha, Style.main.primaryColor,
                    Style.lightGrey)
            ),
          ],
        )
    );
  }

  mostrarSenha() {
    setState(() {
      if(_nomeController.text.isNotEmpty && _emailController.text.isNotEmpty && Validators.email(_emailController.text)){
        _usuario.email = _emailController.text.trim();
        _usuario.name = _nomeController.text.trim();
        registroSenha = true;
      } else {
        mostrarMensagem("Preencha todos os campos");
      }
    });
  }
}

class _SenhaForm extends StatefulWidget {
  @override
  _SenhaFormState createState() => _SenhaFormState();
}

class _SenhaFormState extends State<_SenhaForm> {
  bool botaoBloqueado = false;

  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _senhaConfirmaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 15.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: TextFormField(
                style: TextStyle(
                  decorationColor: Style.lightGrey,
                  color: Colors.white
                ),
                decoration: InputDecoration(
                  labelText: 'Escolha uma senha',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white54
                    ),
                  ),
                ),
                obscureText: true,
                controller: _senhaController,
                autovalidate: true,
                validator: (val) => !val.isNotEmpty && val.length < 6 ? 'Mínimo 6 caracteres' : null,
              )
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(

                  style: TextStyle(
                      decorationColor: Style.lightGrey,
                      color: Colors.white
                  ),
                  decoration: InputDecoration(
                    labelText: 'Confirme a senha',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white54
                      ),
                    ),
                  ),
                  obscureText: true,
                  controller: _senhaConfirmaController,
                  autovalidate: true,
                  validator: (val) => val != _senhaController.text ? 'Confirmação incorreta' : null,
                )
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: StandardButton("Confirmar", criaUsuario,
                  Style.main.primaryColor, Style.lightGrey),
            ),
          ],
        )
    );
  }

  criaUsuario(){
    if(botaoBloqueado) return;
    botaoBloqueado = true;

    mostrarMensagem("Aguarde...", cor: Colors.green, loading: true);
    if(_senhaConfirmaController.text.isNotEmpty && _senhaController.text.isNotEmpty
        && _senhaController.text == _senhaConfirmaController.text){
      _auth.createUserWithEmailAndPassword(
          email: _usuario.email,
          password: _senhaController.text).then(adicionaBanco)
          .catchError(erroCadastro);
    } else {
      mostrarMensagem("Confirmação incorreta");
      botaoBloqueado = false;
    }
  }

  adicionaBanco(FirebaseUser user){
    Firestore.instance.collection(User.collectionName).document(user.uid)
        .setData(_usuario.toJson())
        .then(sucessoCadastro).catchError(erroCadastro) ;
    MyApp.firebaseUser = user;
    _usuario.reference = Firestore.instance.collection(User.collectionName).document(user.uid);
  }

  sucessoCadastro(dynamic) {
    _auth.signOut();
    botaoBloqueado = false;
    _aguardeAtivacaoDialog();
  }

  erroCadastro(){
    mostrarMensagem("Erro no cadastro");
    botaoBloqueado = false;
  }

  Future<void> _aguardeAtivacaoDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aguarde a ativação'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Sua conta foi criada, mas ainda precisa ser ativada pela'
            ' nossa equipe. Você receberá um email assim que puder usá-la.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.popUntil(context,
                    ModalRoute.withName('/login')
                );
              },
            ),
          ],
        );
      },
    );
  }
}

mostrarMensagem(String mensagem, {Color cor=Colors.red, bool loading=false}){
  esconderMensagem();
  _scaffoldKey.currentState.showSnackBar(
    SnackBar(
      content: Row(
        children: <Widget>[
          loading ? CircularProgressIndicator() : Container(height: 0,),
          Text(mensagem),
        ],
      ),
      backgroundColor: cor,
      duration: Duration(seconds: 3),
    )
  );
}

esconderMensagem(){
  _scaffoldKey.currentState.hideCurrentSnackBar();
}