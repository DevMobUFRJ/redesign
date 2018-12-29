import 'package:firebase_auth/firebase_auth.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
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
}