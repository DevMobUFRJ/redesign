import 'package:flutter/material.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/rede/rede_lista.dart';
import 'package:redesign/widgets/item_lista_simples.dart';
import 'package:redesign/widgets/tela_base.dart';

class RedeTela extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return TelaBase (
      title: "Rede",
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              ItemListaSimples('Favoritos', () => listarFavoritos(context), iconeExtra: Icon(Icons.star, color: Tema.principal.primaryColor,),),
              ItemListaSimples('Laboratórios', () => listar("Laboratorio", context)),
              ItemListaSimples('Escolas', () => listar("Escola", context)),
              ItemListaSimples('Incubadoras',  () => listar("Incubadora", context)),
              ItemListaSimples('Bolsistas (PARA TESTES)', () => listar("Bolsista", context)),
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
