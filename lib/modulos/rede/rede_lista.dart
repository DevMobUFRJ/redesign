import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_pessoa.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/widgets/tela_base.dart';

class RedeLista extends StatefulWidget {
  final String ocupacao;

  RedeLista(this.ocupacao, {Key key}) : super(key: key);

  @override
  RedeListaState createState() => RedeListaState(ocupacao);
}

class RedeListaState extends State<RedeLista> {
  final String ocupacao;

  RedeListaState(this.ocupacao);

  @override
  Widget build(BuildContext context) {
    return TelaBase(
        title: ocupacao,
        body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(Usuario.collectionName)
          .where("ocupacao", isEqualTo: this.ocupacao)
          .orderBy("nome")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(
        children: [
          Expanded(
            child:  ListView(
              children: snapshot.map((data) => _buildListItem(context, data)).toList(),
            ),
          ),
        ]
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    Usuario usuario;
    Instituicao instituicao;

    if(data.data['tipo'] == TipoUsuario.pessoa) {
      usuario = Usuario.fromMap(data.data);
    } else {
      instituicao = Instituicao.fromMap(data.data);
    }

    return Container(
      key: ValueKey(data.documentID),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: instituicao == null ?
            _buildUsuario(context, usuario) :
            _buildInstituicao(context, instituicao)
      ),
    );
  }

  Widget _buildUsuario(BuildContext context, Usuario usuario){
    return ListTile(
      title: Text(usuario.nome),
      subtitle: Text("sou um usuário"),
      trailing: Text(">"),
      onTap: () =>
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PerfilPessoa(usuario: usuario),
            ),
          ),
    );
  }

  Widget _buildInstituicao(BuildContext context, Instituicao instituicao){
    return ListTile(
      title: Text(instituicao.nome),
      subtitle: Text("sou uma instituicao"),
      trailing: Text(">"),
      onTap: () =>
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PerfilInstituicao(instituicao: instituicao),
            ),
          ),
    );
  }
}