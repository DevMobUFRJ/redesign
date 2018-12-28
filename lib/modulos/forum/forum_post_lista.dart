import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/forum/forum_post.dart';
import 'package:redesign/modulos/forum/forum_post_exibir.dart';
import 'package:redesign/modulos/forum/forum_post_form.dart';
import 'package:redesign/modulos/forum/forum_tema.dart';
import 'package:redesign/widgets/tela_base.dart';

class ForumPostLista extends StatefulWidget {
  ForumTema tema;

  ForumPostLista(this.tema);

  @override
  ForumPostListaState createState() => ForumPostListaState(tema);
}

class ForumPostListaState extends State<ForumPostLista> {
  ForumTema tema;

  ForumPostListaState(this.tema);

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: tema.titulo,
      body: _buildBody(context),
      fab: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForumPostForm(tema),
            ),
          ),
          child: Icon(Icons.add),
          backgroundColor: Tema.principal.primaryColor,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(ForumPost.collectionName)
          .where("temaId", isEqualTo: tema.reference.documentID)
          .orderBy("data", descending: true)
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
    ForumPost post = ForumPost.fromMap(data.data);

    return Container(
      key: ValueKey(data.documentID),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(post.titulo),
          trailing: Text(">"),
          onTap: () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForumPostExibir(post),
                ),
              ),
        ),
      ),
    );
  }
}