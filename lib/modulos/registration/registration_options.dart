import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/registration/registration_data.dart';
import 'package:redesign/widgets/standard_button.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/user/user.dart';

class RegistrationOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 15, 34, 38),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: ListView(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                logo(),
                _RegistrationPage(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget logo() {
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

class _RegistrationPage extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<_RegistrationPage> {
  String option = "";

  Future<bool> _onWillPop() {
    return _onBack();
  }

  _onBack() {
    setState(() {
      option = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (option) {
      case "":
        return registerOptions();
        break;
      case "universidade":
        return WillPopScope(child: universityOptions(), onWillPop: _onWillPop,);
        break;
      case "escola":
        return WillPopScope(child: schoolOptions(), onWillPop: _onWillPop,);
        break;
      case "incubadora":
        return WillPopScope(child: incubatorOptions(), onWillPop: _onWillPop,);
        break;
      case "outra":
        return WillPopScope(child: incubatorOptions(), onWillPop: _onWillPop,);
        break;
    }
    return null;
  }

  universityRegister() {
    setState(() {
      option = "universidade";
    });
  }

  schoolRegister() {
    setState(() {
      option = "escola";
    });
  }

  incubatorRegister() {
    setState(() {
      option = "incubadora";
    });
  }

  otherRegister() {
    setState(() {
      option = "outra";
    });
  }

  Widget registerOptions() {
    return Column(
      children: <Widget>[
        text("Olá! Para começar, informe sua origem."),
        StandardButton("Universidade", universityRegister, Style.buttonBlue,
            Style.lightGrey),
        StandardButton(
            "Escola", schoolRegister, Style.buttonBlue, Style.lightGrey),
        StandardButton(
            "Incubadora", incubatorRegister, Style.buttonBlue, Style.lightGrey),
        StandardButton(
            "Outra",
            () => registerData(UserType.person, Occupation.outra),
            Style.buttonGrey,
            Style.lightGrey),
      ],
    );
  }

  Widget universityOptions() {
    return Column(
      children: <Widget>[
        text("Você é ..."),
        StandardButton(
            "Bolsista",
            () => registerData(UserType.person, Occupation.bolsista),
            Style.buttonBlue,
            Style.lightGrey),
        StandardButton(
            "Professor(a)",
            () => registerData(UserType.person, Occupation.professor),
            Style.buttonBlue,
            Style.lightGrey),
        StandardButton(
            "Estudante",
            () => registerData(UserType.person, Occupation.discente),
            Style.buttonBlue,
            Style.lightGrey),
        StandardButton(
            "Laboratório",
            () =>
                registerData(UserType.institution, Occupation.laboratorio),
            Style.buttonBlue,
            Style.lightGrey),
        StandardButton(
            "Outro(a)",
            () => registerData(UserType.person, Occupation.outra),
            Style.buttonGrey,
            Style.lightGrey),
      ],
    );
  }

  Widget schoolOptions() {
    return Column(
      children: <Widget>[
        text("Você é ..."),
        StandardButton(
            "Aluno(a)",
            () => registerData(UserType.person, Occupation.aluno),
            Style.purple,
            Style.lightGrey),
        StandardButton(
            "Professor(a)",
            () => registerData(UserType.person, Occupation.professor),
            Style.purple,
            Style.lightGrey),
        StandardButton(
            "Escola",
            () => registerData(UserType.institution, Occupation.escola),
            Style.purple,
            Style.lightGrey),
      ],
    );
  }

  Widget incubatorOptions() {
    return Column(
      children: <Widget>[
        text("Você é ..."),
        StandardButton(
            "Empreendedor(a)",
            () =>
                registerData(UserType.institution, Occupation.empreendedor),
            Style.yellow,
            Style.lightGrey),
        StandardButton(
            "Incubadora",
            () => registerData(UserType.institution, Occupation.incubadora),
            Style.yellow,
            Style.lightGrey),
      ],
    );
  }

  registerData(UserType userType, String occupation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationData(
          type: userType,
          occupation: occupation,
        ),
      ),
    );
  }
}

Widget text(String text) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Container(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white, fontSize: 15, fontFamily: "Montserrat"),
        ),
      ),
    ],
  );
}
