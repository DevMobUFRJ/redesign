import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/servicos/validadores.dart';
import 'package:redesign/widgets/botao_padrao.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class EsqueciSenha extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Center(
            child: Container(
                color: Tema.darkBackground,
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
                    _EsqueciPage(),
                  ],
                )
            )
        )
    );
  }
}

class _EsqueciPage extends StatefulWidget {
  @override
  _EsqueciState createState() => _EsqueciState();
}

class _EsqueciState extends State<_EsqueciPage> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  style: TextStyle(
                      decorationColor: Tema.cinzaClaro,
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
                  controller: emailController,
                  autovalidate: true,
                  validator: (val) => Validadores.email(val) ? null : 'Email inválido',
                )
            ),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: BotaoPadrao("Recuperar Senha", enviarEmail,
                  Tema.principal.primaryColor, Tema.cinzaClaro
              ),
            ),
          ],
        )
    );
  }

  enviarEmail(){
    // TODO A função catchError tem um bug que será resolvido na versão 0.7.0
    // do pacote firebase_auth. Até lá, não da pra saber quando deu erro, talvez
    // só se usar um timeout, podemos considerar depois. (George, 03/01/2019)
    FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text)
        .then(emailEnviado)
        .catchError(erroEnvio);
  }

  emailEnviado(dynamic){
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Email de recuperação enviado."),
          duration: Duration(seconds: 4),
          backgroundColor: Colors.green,
        )
    );
  }

  erroEnvio(){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text("Erro no envio do email"),
        duration: Duration(seconds: 4),
        backgroundColor: Colors.red,
      )
    );
  }
}
