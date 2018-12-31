import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/forum/forum_comentario.dart';
import 'package:redesign/modulos/forum/forum_comentario_form.dart';
import 'package:redesign/modulos/forum/forum_post.dart';
import 'package:redesign/widgets/botao_padrao.dart';
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
            color: Color.fromARGB(255, 15, 34, 38),
            padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 45.0,
                      height: 45.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            //TODO Imagem do usuário if tem imagem. Else, placeholder.
                            image: AssetImage("images/perfil_placeholder.png"),
                          )),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  post.titulo,
                                  style: TextStyle(
                                      color: Tema.buttonBlue, fontSize: 20),
                                ),
                                Text(
                                  "por ${post.criadoPor}",
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
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
          BotaoPadrao("Contribuir", contribuir, Tema.principal.primaryColor,
              Colors.white),
        ],
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
      child: ListView(
          children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
          color: Color.fromARGB(255, 15, 34, 38),
          child: Text(
            post.descricao,
            style: TextStyle(color: Colors.white),
          ),
        )
      ]..addAll(
              snapshot.map((data) => _buildListItem(context, data)).toList(),
            )),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    ForumComentario comentario =
        ForumComentario.fromMap(data.data, reference: data.reference);
    return Column(
      children: <Widget>[
        ExpansionTile(
          title: Column(
            children: <Widget>[
              Container(
                  key: ValueKey(data.documentID),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 45.0,
                        height: 45.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              //TODO Imagem do usuário if tem imagem. Else, placeholder.
                              image:
                                  AssetImage("images/perfil_placeholder.png"),
                            )),
                      ),
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
                                          color: Tema.buttonBlue, fontSize: 20),
                                    ),
                                    Text(
                                      post.criadoPor,
                                      style: TextStyle(color: Colors.black54),
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
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Text(comentario.descricao),
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
}