import 'package:flutter/material.dart';
import 'package:redesign/modulos/cadastro/registroDados.dart';
import 'package:redesign/widgets/botao_padrao.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';

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
    return Container(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: Column(
        children: <Widget>[
          texto("Olá! para começar, informe sua origem."),
          BotaoPadrao("Universidade", UniversidadeRegistro, Tema.buttonBlue,
              Tema.cinzaClaro),
          BotaoPadrao(
              "Escola", EscolaRegistro, Tema.buttonBlue, Tema.cinzaClaro),
          BotaoPadrao("Incubadora", IncubadoraRegistro, Tema.buttonBlue,
              Tema.cinzaClaro),
          BotaoPadrao("Outra", OutraRegistro, Tema.buttonGrey, Tema.cinzaClaro),
        ],
      ),
    );
  }

  Widget OpcoesUniversidade() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: Column(
        children: <Widget>[
          texto("Você é ..."),
          BotaoPadrao("Bolsista", () => cadastroDados(TipoUsuario.pessoa,"Bolsista"), Tema.buttonBlue, Tema.cinzaClaro),
          BotaoPadrao("Professor(a)", () => cadastroDados(TipoUsuario.pessoa, "Professor"), Tema.buttonBlue, Tema.cinzaClaro),
          BotaoPadrao("Estudante", () => cadastroDados(TipoUsuario.pessoa, "Discente"), Tema.buttonBlue, Tema.cinzaClaro),
        ],
      ),
    );
  }
  Widget OpcoesEscola() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: Column(
        children: <Widget>[
          texto("Você é ..."),
          BotaoPadrao("Bolsista", () => cadastroDados(TipoUsuario.pessoa, "Bolsista"), Tema.purple, Tema.cinzaClaro),
          BotaoPadrao("Professor(a)", () => cadastroDados(TipoUsuario.pessoa, "Professor"), Tema.purple, Tema.cinzaClaro),
        ],
      ),
    );
  }
  Widget OpcoesIncubadora() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: Column(
        children: <Widget>[
          texto("Você é ..."),
          BotaoPadrao("Empreendedor(a)", () => cadastroDados(TipoUsuario.pessoa,"Empreendedor"), Tema.yellow, Tema.cinzaClaro),
          BotaoPadrao("Incubadora", () => cadastroDados(TipoUsuario.instituicao, "Incubadora"), Tema.yellow, Tema.cinzaClaro),
        ],
      ),
    );
  }

  cadastroDados(TipoUsuario tipoUsuario , String ocupacao) {
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