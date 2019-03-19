import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/forum/forum_comentario.dart';
import 'package:redesign/modulos/forum/forum_comentario_form.dart';
import 'package:redesign/modulos/forum/forum_post.dart';
import 'package:redesign/services/helper.dart';
import 'package:redesign/widgets/standard_button.dart';
import 'package:redesign/widgets/dados_asincronos.dart';
import 'package:redesign/widgets/tela_base_forum_post.dart';

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
    return TelaBaseForum(
      title: post.titulo,
      body: Column(
        children: <Widget>[
          Container(
            color: Style.darkBackground,
            padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 10),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatarAsync(post.criadoPor, radius: 26, clicavel: true,),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.only(left: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    post.titulo,
                                    style: TextStyle(
                                      color: Style.primaryColorLighter,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    softWrap: false,
                                    overflow: TextOverflow.clip,
                                  ),
                                  NomeTextAsync(
                                    post.criadoPor,
                                    TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          _ListaComentarios(
              post.reference.collection(ForumComentario.collectionName), post),
        ],
      ),
    );
  }
}

class _ListaComentarios extends StatefulWidget {
  final CollectionReference reference;
  final ForumPost post;

  _ListaComentarios(this.reference, this.post);

  @override
  _ListaComentariosState createState() =>
      _ListaComentariosState(reference, post);
}

class _ListaComentariosState extends State<_ListaComentarios> {
  CollectionReference reference;
  final ForumPost post;

  _ListaComentariosState(this.reference, this.post);

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
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          ListView(
              children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
              color: Style.darkBackground,
              child: Text(
                post.descricao,
                style: TextStyle(color: Colors.white),
              ),
            )
          ]
            ..addAll(
              snapshot.map((data) => _buildListItem(context, data)).toList()
            )
            // Padding extra no final da lista
            ..add(Container(padding: EdgeInsets.only(bottom: 60.0),))
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: StandardButton("Contribuir", contribuir, Style.main.primaryColor,
                Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    ForumComentario comentario =
        ForumComentario.fromMap(data.data, reference: data.reference);
    return Column(
      key: Key(data.documentID),
      children: <Widget>[
        ExpansionTile(
          title: Column(
            children: <Widget>[
              Container(
                  key: ValueKey(data.documentID),
                  child: Row(
                    children: <Widget>[
                      CircleAvatarAsync(comentario.criadoPor, radius: 23, clicavel: true,),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      comentario.titulo,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Style.buttonBlue, fontSize: 18),
                                    ),
                                    NomeTextAsync(
                                      post.criadoPor,
                                      TextStyle(color: Colors.black54, fontSize: 14),
                                      prefixo: "",
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
            ],
          ),
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 15, bottom: 5),
              child: Text("Em " + Helper.convertToDMYString(comentario.data),
                 style: TextStyle(
                   fontSize: 11,
                   color: Colors.black45,
                 ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Text(comentario.descricao,
                textAlign: TextAlign.justify,
              ),
            )
          ],
        ),
        myDivider()
      ],
    );
  }

  Widget myDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Divider(
        color: Colors.black54,
      ),
    );
  }

  contribuir() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ForumComentarioForm(
              post.reference.collection(ForumComentario.collectionName))),
    );
  }
}