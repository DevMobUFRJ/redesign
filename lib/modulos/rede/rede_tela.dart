import 'package:flutter/material.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/rede/rede_lista.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
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
              ItemListaSimples('Favoritos', () => listar("Favoritos", context), iconeExtra: Icon(Icons.star, color: Tema.principal.primaryColor,),),
              ItemListaSimples('Laboratórios', () => listar(Ocupacao.laboratorio, context)),
              ItemListaSimples('Escolas', () => listar(Ocupacao.escola, context)),
              ItemListaSimples('Incubadoras',  () => listar(Ocupacao.incubadora, context)),
              ItemListaSimples('Bolsistas (PARA TESTES)', () => listar(Ocupacao.bolsista, context)),
            ],
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
