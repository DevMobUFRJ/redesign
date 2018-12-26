import 'package:flutter/material.dart';

class PaginaOpcoes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 15, 34, 38),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 200.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(125.0),
                      image: DecorationImage(
                          image: AssetImage('images/logo_novo.png')
                      )
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Text("Olá! Para começar, informe sua origem.",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: "Montserrat"
                      ),
                    ),
                  )
                ],),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Column(
                    children: <Widget>[
                      Botao("Universidade", "azul"),
                      Botao("Escola", "azul"),
                      Botao("Incubadora", "azul"),
                      Botao("Outra", "cinza"),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
    );
  }

  Widget Botao (String texto, String cor){

    var corBotao ;

    if(cor == "cinza" ){
      corBotao = Color.fromARGB(255, 48, 67, 76);
    }else{
      corBotao = Color.fromARGB(255, 52, 116, 128);
    }

    return Row(
      children: <Widget>[
        Expanded(
            child:GestureDetector(
            child: Container(
                padding: EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.center,
                height: 50.0,
                decoration: BoxDecoration(
                  color: corBotao,
                  borderRadius: BorderRadius.circular(100.0)
                ),
                child: Text(
                  texto,
                  style: TextStyle(
                    color: Colors.white,fontSize: 20
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ), onTap: ()=> debugPrint('botao : $texto'),
            )
        ),
      ],
    );
  }
}