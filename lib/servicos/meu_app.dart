import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_pessoa.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/servicos/helper.dart';

class MeuApp {
  static FirebaseUser firebaseUser;
  static List<int> imagemMemory;
  /// Deve usar apenas um dos campos abaixo, usuario ou instituicao
  /// de acordo com o tipo do firebaseUser;
  static Usuario usuario;
  static Instituicao instituicao;

  static bool ativo() => firebaseUser != null ? (usuario != null ? usuario.ativo : instituicao.ativo) : false;
  static String userId() => firebaseUser != null ? firebaseUser.uid : null;
  static String nome() => usuario != null ? usuario.nome : instituicao != null ? instituicao.nome : "";
  static String ocupacao() => usuario != null ? usuario.ocupacao : instituicao != null ? instituicao.ocupacao : "";
  static bool ehEstudante() => usuario != null && usuario.ocupacao == Ocupacao.aluno; //Alunos tem regras especiais no app

  static bool ehLabDis() => instituicao != null &&
      firebaseUser.email == Helper.emailLabdis;

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
    Navigator.pushReplacementNamed(context, '/login');
    MeuApp.firebaseUser = null;
    MeuApp.usuario = null;
    MeuApp.instituicao = null;
    MeuApp.imagemMemory = null;
  }

  static void atualizarImagem(){
    if(imagemMemory == null && userId() != null){
      FirebaseStorage.instance.ref().child("perfil/" + userId() + ".jpg").getData(38000).then(salvaImagem);
    }
  }

  static void salvaImagem(List<int> bytes){
    imagemMemory = bytes;
  }

  static DocumentReference getReferenciaUsuario(){
    if(usuario != null){
      return usuario.reference;
    } else if (instituicao != null){
      return instituicao.reference;
    }
    return null;
  }
}