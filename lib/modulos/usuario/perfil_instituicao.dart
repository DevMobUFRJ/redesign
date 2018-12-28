import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
import 'package:redesign/widgets/tela_base.dart';

class PerfilInstituicao extends StatelessWidget {

  final Instituicao instituicao;

  PerfilInstituicao({this.instituicao});

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: instituicao.nome,
      body: Text("Ih, é a " + instituicao.nome),
    );
  }
}