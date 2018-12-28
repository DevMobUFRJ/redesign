import 'package:firebase_auth/firebase_auth.dart';
import 'package:redesign/modulos/usuario/usuario.dart';

class MeuApp {

  static FirebaseUser firebaseUser;
  static Usuario usuario;

  static String userId() => firebaseUser != null ? firebaseUser.uid : null;
}