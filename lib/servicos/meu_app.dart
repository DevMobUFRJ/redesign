import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_pessoa.dart';
import 'package:redesign/modulos/usuario/usuario.dart';

class MeuApp {

  static final FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseUser firebaseUser;
  static List<int> imagemMemory;

  /// Deve usar apenas um dos campos abaixo, usuario ou instituicao
  /// de acordo com o tipo do firebaseUser;
  static Usuario usuario;
  static Instituicao instituicao;

  static String userId() => firebaseUser != null ? firebaseUser.uid : null;
  static String nome() => usuario != null ? usuario.nome : instituicao != null ? instituicao.nome : "";
  static String ocupacao() => usuario != null ? usuario.ocupacao : instituicao != null ? instituicao.ocupacao : "";

  static bool ehLabDis() => true || //instituicao != null && TODO
      instituicao.email == "labdis@gmail.com";

  /// Retorna uma função a ser
  static void irProprioPerfil(BuildContext context){
    if(usuario != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PerfilPessoa(usuario),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PerfilInstituicao(instituicao),
        ),
      );
    }
  }

  static void startup(){
    atualizarImagem();
  }

  static void setUsuario(Usuario usuario){
    if(usuario.tipo == TipoUsuario.instituicao){
      MeuApp.instituicao = usuario;
      MeuApp.usuario = null;
    } else {
      MeuApp.usuario = usuario;
      MeuApp.instituicao = null;
    }
  }

  static void logout(BuildContext context){
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.signOut();
    Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
    MeuApp.firebaseUser = null;
    MeuApp.usuario = null;
    MeuApp.instituicao = null;
    MeuApp.imagemMemory = null;
  }

  static void atualizarImagem(){
    if(imagemMemory == null){
      storage.ref().child("perfil/" + userId() + ".jpg").getData(38000).then(salvaImagem);
    }
  }

  static void salvaImagem(List<int> bytes){
    imagemMemory = bytes;
  }
}