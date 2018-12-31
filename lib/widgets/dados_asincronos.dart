
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/usuario/usuario.dart';

/// Recebe o ID do usuário como parâmetro pra obter o nome.
/// Gera um Stateful Text com o nome do usuário.
///
/// Esse widget é necessário porque a consulta no firebase é asíncrona
/// então precisaríamos de um stateful widget pra cada elemento da lista ou
/// pros trechos asíncronos.
class NomeTextAsync extends StatefulWidget {
  final String usuario;
  final TextStyle style;
  final String prefixo;

  const NomeTextAsync(this.usuario, this.style, {this.prefixo = "por"});

  @override
  _NomeTextState createState() => _NomeTextState(usuario, style, prefixo);
}

class _NomeTextState extends State<NomeTextAsync> {
  final String usuario;
  final TextStyle style;
  final String prefixo;
  String nome = "";

  _NomeTextState(this.usuario, this.style, this.prefixo){
    if(usuario != null && usuario.isNotEmpty){
      DocumentReference ref = Firestore.instance.collection(
          Usuario.collectionName).document(usuario);
      try {
        ref.get().then(atualizarNome);
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    String texto = "";
    if(nome != ""){
      texto = prefixo + " " + nome;
    }

    return Text(texto, style: style);
  }

  atualizarNome(DocumentSnapshot user){
    try{
      String nomeNovo = user.data['nome'];
      if(nomeNovo != null)
        setState(() {
          nome = nomeNovo;
        });
    } catch(e){}
  }
}