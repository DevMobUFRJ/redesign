import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/style.dart';

class ItemListaSimples extends StatelessWidget {

  final String titulo;
  final String subtitulo;
  final VoidCallback callback;
  final Widget iconeExtra;
  final Color corTexto;
  final VoidCallback onLongPress;

  ItemListaSimples(this.titulo, this.callback, {Key key, this.iconeExtra, this.corTexto = Style.primaryColor, this.subtitulo, this.onLongPress}) : super(key: key);

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
            subtitle: subtitulo != null && subtitulo.isNotEmpty ? Text(this.subtitulo) : null,
            contentPadding: EdgeInsets.only(top: 2, bottom: 2),
            onLongPress: onLongPress,
          ),
          Divider(color: Colors.black38),
        ],
      ),
    );
  }

}