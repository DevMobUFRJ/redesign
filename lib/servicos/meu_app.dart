import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_pessoa.dart';
import 'package:redesign/modulos/usuario/usuario.dart';

class MeuApp {

  static FirebaseUser firebaseUser;

  /// Deve usar apenas um dos campos abaixo, usuario ou instituicao
  /// de acordo com o tipo do firebaseUser;
  static Usuario usuario;
  static Instituicao instituicao;

  static String userId() => firebaseUser != null ? firebaseUser.uid : null;

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
}