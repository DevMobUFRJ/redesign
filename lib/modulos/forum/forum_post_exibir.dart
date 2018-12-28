import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/forum/forum_post.dart';
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
      body: Text(post.descricao),
    );
  }
}