import 'package:flutter/material.dart';
import 'package:redesign/modulos/cadastro/registroDados.dart';
import 'package:redesign/widgets/standard_button.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/modulos/usuario/user.dart';

class RegistroOpcoes extends StatelessWidget {

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
                _RegisterPage()
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

class _RegisterPage extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<_RegisterPage> {

  String opcao = "";

  @override
  Widget build(BuildContext context) {
    switch (opcao) {
      case "":
        return OpcoesCadastro();
        break;
      case "universidade":
        return OpcoesUniversidade();
        break;
      case "escola":
        return OpcoesEscola();
        break;
      case "incubadora":
        return OpcoesIncubadora();
        break;
      case "outra":
        return OpcoesIncubadora();
        break;
    }
    return null;
  }

  UniversidadeRegistro() {
    setState(() {
      opcao = "universidade";
    });
  }

  EscolaRegistro() {
    setState(() {
      opcao = "escola";
    });
  }

  IncubadoraRegistro() {
    setState(() {
      opcao = "incubadora";
    });
  }

  OutraRegistro() {
    setState(() {
      opcao = "outra";
    });
  }


  Widget OpcoesCadastro() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: ListView(
          children: <Widget>[
            texto("Olá! para começar, informe sua origem."),
            StandardButton("Universidade", UniversidadeRegistro, Style.buttonBlue,
                Style.lightGrey),
            StandardButton( "Escola", EscolaRegistro, Style.buttonBlue,
                Style.lightGrey),
            StandardButton("Incubadora", IncubadoraRegistro, Style.buttonBlue,
                Style.lightGrey),
            StandardButton("Outra",
                () => cadastroDados(UserType.person, Occupation.outra),
                Style.buttonGrey, Style.lightGrey),
          ],
        ),
      ),
    );
  }

  Widget OpcoesUniversidade() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: ListView(
          children: <Widget>[
            texto("Você é ..."),
            StandardButton("Bolsista", () => cadastroDados(UserType.person, Occupation.bolsista), Style.buttonBlue, Style.lightGrey),
            StandardButton("Professor(a)", () => cadastroDados(UserType.person, Occupation.professor), Style.buttonBlue, Style.lightGrey),
            StandardButton("Estudante", () => cadastroDados(UserType.person, Occupation.discente), Style.buttonBlue, Style.lightGrey),
            StandardButton("Laboratório", () => cadastroDados(UserType.institution, Occupation.laboratorio), Style.buttonBlue, Style.lightGrey),
            StandardButton("Outro(a)", () => cadastroDados(UserType.person, Occupation.outra), Style.buttonGrey, Style.lightGrey),
          ],
        ),
      ),
    );
  }
  Widget OpcoesEscola() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: ListView(
          children: <Widget>[
            texto("Você é ..."),
            StandardButton("Aluno(a)", () => cadastroDados(UserType.person, Occupation.aluno), Style.purple, Style.lightGrey),
            StandardButton("Professor(a)", () => cadastroDados(UserType.person, Occupation.professor), Style.purple, Style.lightGrey),
            StandardButton("Escola", () => cadastroDados(UserType.institution, Occupation.escola), Style.purple, Style.lightGrey),
          ],
        ),
      ),
    );
  }
  Widget OpcoesIncubadora() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: ListView(
          children: <Widget>[
            texto("Você é ..."),
            StandardButton("Empreendedor(a)", () => cadastroDados(UserType.institution, Occupation.empreendedor), Style.yellow, Style.lightGrey),
            StandardButton("Incubadora", () => cadastroDados(UserType.institution, Occupation.incubadora), Style.yellow, Style.lightGrey),
          ],
        ),
      ),
    );
  }

  cadastroDados(UserType tipoUsuario , String ocupacao) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistroDados(tipo: tipoUsuario, ocupacao: ocupacao,)),
    );
  }
}

Widget texto (String texto){
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Container(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: Text("$texto",
          style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: "Montserrat"
          ),
        ),
      )
    ],);
}