import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/forum/forum_post.dart';
import 'package:redesign/modulos/forum/forum_tema.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/tela_base.dart';

class ForumPostForm extends StatefulWidget {
  ForumTema tema;

  ForumPostForm(this.tema);

  @override
  ForumPostFormState createState() => ForumPostFormState(tema);
}

class ForumPostFormState extends State<ForumPostForm> {
  ForumTema tema;

  ForumPostFormState(this.tema);

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: "Nova Postagem",
      body: Text("Formulário"),
    );
  }

  savePost(ForumPost post){
    Firestore.instance.collection(ForumPost.collectionName).add(post.toJson()).then(saved); //TODO pegar o erro
  }

  saved(DocumentReference doc){
    Navigator.pop(context);
  }
}