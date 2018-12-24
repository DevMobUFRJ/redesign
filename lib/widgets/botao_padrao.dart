import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';

class BotaoPadrao extends StatelessWidget {

  final String titulo;
  final Color corFundo;
  final Color corTexto;
  final VoidCallback callback;

  BotaoPadrao( this.titulo, this.callback, this.corFundo, this.corTexto);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RaisedButton(
      child: Text(
        this.titulo,
        style: TextStyle(
          color: corTexto,
          fontSize: 16,
        ),
      ),
      color: corFundo,
      textColor: corTexto,
      onPressed: callback,
      shape: StadiumBorder(),
      padding: EdgeInsets.all(16),
    );
  }

}