import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BotaoPadrao extends StatelessWidget {

  final String titulo;
  final Color corFundo;
  final Color corTexto;
  final VoidCallback callback;

  BotaoPadrao(this.titulo, this.callback, this.corFundo, this.corTexto);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: GestureDetector(
              child: Container(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  decoration: BoxDecoration(
                      color: corFundo,
                      borderRadius: BorderRadius.circular(100.0)
                  ),
                  child: Text(
                    titulo,
                    style: TextStyle(
                        color: corTexto, fontSize: 15
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ), onTap: callback,
            )
        ),
      ],
    );
  }
}
//return RaisedButton(
//child: Text(
//this.titulo,
//style: TextStyle(
//color: corTexto,
//fontSize: 16,
//),
//),
//color: corFundo,
//textColor: corTexto,
//onPressed: callback,
//shape: StadiumBorder(),
//padding: EdgeInsets.all(16),
