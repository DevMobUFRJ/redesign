import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:redesign/modulos/user/institution.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/services/validators.dart';
import 'package:redesign/widgets/standard_button.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/styles/style.dart';

User _user;
FirebaseAuth _auth = FirebaseAuth.instance;
GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class RegistrationData extends StatelessWidget {
  String occupation;
  UserType type;

  RegistrationData({this.occupation, this.type}) {
    if (_user == null) {
      if (type == UserType.person) {
        _user = User();
      } else {
        _user = Institution();
      }
      _user.occupation = occupation;
      _user.type = type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color.fromARGB(255, 15, 34, 38),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: ListView(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _logo(),
                _RegistrationForm(),
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget _logo() {
  return Padding(
    padding: EdgeInsets.only(top: 38, bottom: 20),
    child: Hero(
      tag: "redesign-logo",
      child: Image.asset(
        'images/rede_logo.png',
        fit: BoxFit.contain,
        width: 120,
      ),
    ),
  );
}

class _RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<_RegistrationForm> {
  bool registerPassword = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<bool> _onWillPop() {
    return _onBack();
  }

  _onBack() {
    setState(() {
      registerPassword = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return registerPassword
        ? WillPopScope(child: _PasswordForm(), onWillPop: _onWillPop,)
        : Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: TextField(
                style: TextStyle(
                  decorationColor: Style.lightGrey, color: Colors.white
                ),
                cursorColor: Style.buttonBlue,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                ),
                controller: _nameController,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: TextFormField(
                style: TextStyle(
                  decorationColor: Style.lightGrey, color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                ),
                controller: _emailController,
                validator: (val) =>
                    Validators.email(val) ? null : 'Email inválido',
              ),
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: StandardButton("Próximo", showPassword,
                    Style.main.primaryColor, Style.lightGrey)),
          ],
        );
  }

  showPassword() {
    setState(() {
      if (_nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          Validators.email(_emailController.text)) {
        _user.email = _emailController.text.trim();
        _user.name = _nameController.text.trim();
        registerPassword = true;
      } else {
        showMessage("Preencha todos os campos");
      }
    });
  }
}

class _PasswordForm extends StatefulWidget {
  @override
  _PasswordFormState createState() => _PasswordFormState();
}

class _PasswordFormState extends State<_PasswordForm> {
  bool buttonBlocked = false;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  style: TextStyle(
                      decorationColor: Style.lightGrey, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Escolha uma senha',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (val) => !val.isNotEmpty && val.length < 6
                      ? 'Mínimo 6 caracteres'
                      : null,
                )),
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  style: TextStyle(
                      decorationColor: Style.lightGrey, color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Confirme a senha',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                  obscureText: true,
                  controller: _confirmPasswordController,
                  validator: (val) => val != _passwordController.text
                      ? 'Confirmação incorreta'
                      : null,
                )),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: StandardButton("Confirmar", createUser,
                  Style.main.primaryColor, Style.lightGrey),
            ),
          ],
        ));
  }

  createUser() {
    if (buttonBlocked) return;
    buttonBlocked = true;

    showMessage("Aguarde...", cor: Colors.green, loading: true);
    if (_confirmPasswordController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text) {
      _auth
          .createUserWithEmailAndPassword(
              email: _user.email, password: _passwordController.text)
          .then(addIntoBank)
          .catchError(errorSignUp);
    } else {
      showMessage("Confirmação incorreta");
      buttonBlocked = false;
    }
  }

  addIntoBank(FirebaseUser user) {
    Firestore.instance
        .collection(User.collectionName)
        .document(user.uid)
        .setData(_user.toJson())
        .then(successSignUp)
        .catchError(errorSignUp);
    MyApp.firebaseUser = user;
    _user.reference =
        Firestore.instance.collection(User.collectionName).document(user.uid);
  }

  successSignUp(dynamic) {
    _auth.signOut();
    buttonBlocked = false;
    _waitActivationDialog();
  }

  errorSignUp() {
    showMessage("Erro no cadastro");
    buttonBlocked = false;
  }

  Future<void> _waitActivationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aguarde a ativação'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Sua conta foi criada, mas ainda precisará ser ativada pela'
                    ' nossa equipe.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/login'));
              },
            ),
          ],
        );
      },
    );
  }
}

showMessage(String message,
    {Color cor = Colors.red, bool loading = false}) {
  hideMessage();
  _scaffoldKey.currentState.showSnackBar(SnackBar(
    content: Row(
      children: <Widget>[
        loading
            ? CircularProgressIndicator()
            : Container(
                height: 0,
              ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(message),
        ),
      ],
    ),
    backgroundColor: cor,
    duration: Duration(seconds: 3),
  ));
}

hideMessage() {
  _scaffoldKey.currentState.hideCurrentSnackBar();
}
