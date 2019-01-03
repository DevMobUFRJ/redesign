import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/usuario/usuario.dart';

/// Idealmente, aqui ficam todos os widgets padronizados para lidar com dados
/// que precisam ser buscados de forma asíncrona do firebase.

/// [NomeTextAsync] Recebe o ID do usuário como parâmetro pra obter o nome.
/// Gera um Stateful Text com o nome do usuário.
class NomeTextAsync extends StatefulWidget {
  final String idUsuario;
  final TextStyle style;
  final String prefixo;

  const NomeTextAsync(this.idUsuario, this.style, {this.prefixo = "por"});

  @override
  _NomeTextState createState() => _NomeTextState(idUsuario, style, prefixo);
}

class _NomeTextState extends State<NomeTextAsync> {
  final String usuario;
  final TextStyle style;
  final String prefixo;
  String nome = "";

  _NomeTextState(this.usuario, this.style, this.prefixo){
    if(usuario != null && usuario.isNotEmpty){
      // Dentro do construtor pois se fosse no build seria repetido toda hora.
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
      if(prefixo.isNotEmpty){
        texto = prefixo + " ";
      }
      texto += nome;
    }

    return Text(texto, style: style, overflow: TextOverflow.clip, maxLines: 1,);
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