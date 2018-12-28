import 'package:flutter/material.dart';
import 'package:redesign/modulos/rede/rede_lista.dart';
import 'package:redesign/widgets/tela_base.dart';

class RedeTela extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return TelaBase (
      title: "Rede",
      body: Center(
        child: new Container(
          margin: new EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
          child: new Column(
            children: <Widget>[
              new ItemLista(text:'Favoritos', onPressed: () => listarFavoritos(context)),
              new Divider(height: 1.0,color: Colors.black45,),
              new ItemLista(text:'Laboratórios', onPressed: () => listar("lab", context)),
              new Divider(height: 1.0,color: Colors.black45,),
              new ItemLista(text:'Escolas', onPressed: () => listar("escola", context)),
              new Divider(height: 1.0,color: Colors.black45,),
              new ItemLista(text:'Incubadoras', onPressed: () => listar("incubadora", context)),
              new Divider(height: 1.0,color: Colors.black45,),
              new ItemLista(text:'Bolsistas (PARA TESTES)', onPressed: () => listar("bolsista", context)),
              new Divider(height: 1.0,color: Colors.black45,),
            ],
          ),
        ),
      ),
    );
  }

  listarFavoritos(context){
    //TODO
  }

  listar(String ocupacao, context){
    Navigator.push( context,
      MaterialPageRoute( builder: (context) => RedeLista(ocupacao) ),
    );
  }
}

class ItemLista extends StatelessWidget{

  final String text;
  final VoidCallback onPressed;

  ItemLista({
    this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(text,
        style: new TextStyle(
          color: new Color.fromARGB(255, 55, 116, 127),
          fontSize: 25.0,
        ),
      ),
      onTap: onPressed,
    );
  }
}
