import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/widgets/tela_base.dart';

class PerfilPessoa extends StatelessWidget {

  final Usuario usuario;

  PerfilPessoa(this.usuario);

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: usuario.nome,
      body: Text("Ih, é o " + usuario.nome),
    );
  }
}