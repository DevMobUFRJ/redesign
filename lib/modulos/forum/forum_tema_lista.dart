import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/forum/forum_post_lista.dart';
import 'package:redesign/modulos/forum/forum_tema.dart';
import 'package:redesign/widgets/tela_base.dart';

class ForumTemaLista extends StatefulWidget {

  @override
  ForumTemaListaState createState() => ForumTemaListaState();
}

class ForumTemaListaState extends State<ForumTemaLista> {

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: "Fórum",
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(ForumTema.collectionName)
          .orderBy("titulo")
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
    ForumTema tema = ForumTema.fromMap(data.data, reference: data.reference);

    return Container(
      key: ValueKey(data.documentID),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
            title: Text(tema.titulo),
            trailing: Text(">"),
            onTap: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForumPostLista(tema),
                  ),
                ),
          ),
      ),
    );
  }
}