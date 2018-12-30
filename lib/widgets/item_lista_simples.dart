import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';

class ItemListaSimples extends StatelessWidget {

  String titulo;
  VoidCallback callback;
  Icon iconeExtra;
  Color corTexto;

  ItemListaSimples(this.titulo, this.callback, {Key key, this.iconeExtra, this.corTexto = Tema.primaryColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(titulo,
              style: TextStyle(
                color: corTexto,
                fontSize: 22.0,
              ),
            ),
            onTap: callback,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                iconeExtra,
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.0,
                  color: Colors.black26,
                ),
              ].where((w) => w != null).toList(),
            ),
          ),
          Divider(color: Colors.black38),
        ],
      ),
    );
  }

}