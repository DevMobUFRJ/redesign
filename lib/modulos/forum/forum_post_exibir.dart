import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/forum/forum_comentario.dart';
import 'package:redesign/modulos/forum/forum_comentario_form.dart';
import 'package:redesign/modulos/forum/forum_post.dart';
import 'package:redesign/widgets/botao_padrao.dart';
import 'package:redesign/widgets/tela_base.dart';

class ForumPostExibir extends StatefulWidget {
  final ForumPost post;

  ForumPostExibir(this.post);

  @override
  ForumPostExibirState createState() => ForumPostExibirState(post);
}

class ForumPostExibirState extends State<ForumPostExibir> {
  final ForumPost post;

  ForumPostExibirState(this.post);

  @override
  Widget build(BuildContext context) {

    return TelaBase(
      title: post.titulo,
      body: Column(
        children: <Widget>[
          Text(post.descricao),
          Text("Comentários:"),
          _ListaComentarios(post.reference.collection(ForumComentario.collectionName)),
          BotaoPadrao("Contribuir", contribuir, Tema.principal.primaryColor, Colors.white),
        ],
      ),
    );
  }

  contribuir(){
    Navigator.push( context,
      MaterialPageRoute( builder: (context) => ForumComentarioForm(post.reference.collection(ForumComentario.collectionName)) ),
    );
  }
}

class _ListaComentarios extends StatefulWidget {
  CollectionReference reference;

  _ListaComentarios(this.reference);

  @override
  _ListaComentariosState createState() => _ListaComentariosState(reference);
}

class _ListaComentariosState extends State<_ListaComentarios> {
  CollectionReference reference;

  _ListaComentariosState(this.reference);

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: reference.orderBy("data", descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Expanded(
      child: ListView(
        children: snapshot.map((data) => _buildListItem(context, data))
            .toList(),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    ForumComentario comentario = ForumComentario.fromMap(data.data, reference: data.reference);

    return Container(
      key: ValueKey(data.documentID),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(comentario.titulo),
          subtitle: Text(comentario.descricao)
        ),
      ),
    );
  }
}