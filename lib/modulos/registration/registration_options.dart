import 'package:flutter/material.dart';
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
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[logo(), _RegistrationPage()],
        ),
      ),
    );
  }
}

Widget logo() {
  return Padding(
    padding: EdgeInsets.only(top: 50, bottom: 20),
    child: Image.asset(
      'images/rede_logo.png',
      fit: BoxFit.fitWidth,
      width: 200,
    ),
  );
}

class _RegistrationPage extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<_RegistrationPage> {
  String option = "";

  @override
  Widget build(BuildContext context) {
    switch (option) {
      case "":
        return registerOptions();
        break;
      case "universidade":
        return universityOptions();
        break;
      case "escola":
        return schoolOptions();
        break;
      case "incubadora":
        return incubatorOptions();
        break;
      case "outra":
        return incubatorOptions();
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
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: ListView(
          children: <Widget>[
            text("Olá! para começar, informe sua origem."),
            StandardButton("Universidade", universityRegister, Style.buttonBlue,
                Style.lightGrey),
            StandardButton(
                "Escola", schoolRegister, Style.buttonBlue, Style.lightGrey),
            StandardButton("Incubadora", incubatorRegister, Style.buttonBlue,
                Style.lightGrey),
            StandardButton(
                "Outra",
                () => registerData(UserType.person, Occupation.outra),
                Style.buttonGrey,
                Style.lightGrey),
          ],
        ),
      ),
    );
  }

  Widget universityOptions() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: ListView(
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
        ),
      ),
    );
  }

  Widget schoolOptions() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: ListView(
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
        ),
      ),
    );
  }

  Widget incubatorOptions() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: ListView(
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
        ),
      ),
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
        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
        child: Text(
          text,
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontFamily: "Montserrat"),
        ),
      ),
    ],
  );
}
