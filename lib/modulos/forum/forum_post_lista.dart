import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/forum/forum_post.dart';
import 'package:redesign/modulos/forum/forum_post_exibir.dart';
import 'package:redesign/modulos/forum/forum_post_form.dart';
import 'package:redesign/modulos/forum/forum_tema.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/dados_asincronos.dart';
import 'package:redesign/widgets/tela_base.dart';

class ForumPostLista extends StatefulWidget {
  final ForumTema tema;

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
      stream: Firestore.instance
          .collection(ForumPost.collectionName)
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
    return Column(children: [
      Expanded(
        child: ListView(
          children:
              snapshot.map((data) => _buildListItem(context, data)).toList(),
        ),
      ),
    ]);
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    ForumPost post = ForumPost.fromMap(data.data, reference: data.reference);
    return _PostItem(post);
  }
}

class _PostItem extends StatefulWidget {
  final ForumPost post;

  _PostItem(this.post);

  @override
  _PostState createState() => _PostState(post);
}

class _PostState extends State<_PostItem> {
  final ForumPost post;
  List<int> imagem;

  _PostState(this.post){
    if(post.criadoPor == MeuApp.userId()){
      imagem = MeuApp.imagemMemory;
    } else {
      FirebaseStorage.instance.ref()
          .child("perfil/" + post.criadoPor + ".jpg")
          .getData(36000).then(achouFoto)
          .catchError((e) {});
    }
  }

  achouFoto(List<int> novaImagem){
    setState(() {
      imagem = novaImagem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Container(
        key: ValueKey(post.reference.documentID),
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
                        image: imagem != null ? MemoryImage(imagem) :
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
                                post.titulo,
                                style: TextStyle(
                                    color: Tema.buttonBlue, fontSize: 18),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                softWrap: false,
                              ),
                              NomeTextAsync(
                                post.criadoPor,
                                TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        //alignment: Alignment.bottomRight,
                        //padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Tema.buttonBlue,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 5),
              child: Divider(
                color: Colors.black54,
              ),
            )
          ],
        ),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForumPostExibir(post, imagem),
        ),
      ),
    );
  }

}
