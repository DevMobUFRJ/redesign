import 'package:flutter/material.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/modulos/rede/rede_lista.dart';
import 'package:redesign/modulos/usuario/user.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/item_lista_simples.dart';
import 'package:redesign/widgets/base_screen.dart';

class RedeTela extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return BaseScreen (
      title: "Rede",
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              ItemListaSimples('Favoritos', () => listar("Favoritos", context), iconeExtra: Icon(Icons.star, color: Style.main.primaryColor,),),
              MyApp.isStudent() ? null : ItemListaSimples('Laboratórios', () => listar(Occupation.laboratorio, context)),
              ItemListaSimples('Escolas', () => listar(Occupation.escola, context)),
              MyApp.isStudent() ? null : ItemListaSimples('Incubadoras',  () => listar(Occupation.incubadora, context)),
            ].where((w) => w != null).toList(),
          ),
        ),
      ),
    );
  }

  listar(String ocupacao, context){
    Navigator.push( context,
      MaterialPageRoute( builder: (context) => RedeLista(ocupacao) ),
    );
  }
}
