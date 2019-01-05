import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/servicos/meu_app.dart';

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

class CircleAvatarAsync extends StatefulWidget {
  final String idUsuario;
  final double radius;

  CircleAvatarAsync(this.idUsuario, {this.radius=20.0});

  @override
  _CircleAvatarAsyncState createState() => _CircleAvatarAsyncState(idUsuario, radius);
}

class _CircleAvatarAsyncState extends State<CircleAvatarAsync> {
  final String idUsuario;
  final double radius;
  List<int> imagem;

  _CircleAvatarAsyncState(this.idUsuario, this.radius){
    if(imagem == null){
      if(idUsuario == MeuApp.userId()){
        imagem = MeuApp.imagemMemory;
      } else {
        FirebaseStorage.instance.ref()
            .child("perfil/" + idUsuario + ".jpg")
            .getData(36000).then(chegouFotoPerfil)
            .catchError((e) => debugPrint("Erro foto"));
      }
    }
  }

  chegouFotoPerfil(List<int> img){
    setState(() {
      imagem = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: imagem == null ?
          AssetImage("images/perfil_placeholder.png")
          : MemoryImage(imagem),
      radius: radius,
    );
  }

}