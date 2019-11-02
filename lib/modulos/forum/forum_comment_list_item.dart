import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:redesign/modulos/forum/forum_comment.dart';
import 'package:redesign/modulos/forum/forum_comment_form.dart';
import 'package:redesign/services/helper.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/widgets/async_data.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentListItem extends StatefulWidget {
  final ForumComment comment;

  /// Explicita se um comentário é de segundo nível, ou seja, comentário de um
  /// comentário. Se for, não mostra opções de responder nem ver respostas.
  final bool isSecondLevel;

  CommentListItem(this.comment, {this.isSecondLevel = false});

  @override
  _CommentListItemState createState() => _CommentListItemState();
}

class _CommentListItemState extends State<CommentListItem> {
  bool showChildren = false;
  int childrenCount = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.isSecondLevel)
      widget.comment.reference
          .collection(ForumComment.collectionName)
          .getDocuments()
          .then((QuerySnapshot snp) {
        setState(() {
          childrenCount = snp.documents.length;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key(widget.comment.reference.documentID),
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: GestureDetector(
              child: ExpansionTile(
                onExpansionChanged: (isExpanded) {
                  if (!isExpanded) {
                    setState(() {
                      showChildren = false;
                    });
                  }
                },
                title: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatarAsync(
                          widget.comment.createdBy,
                          radius: 23,
                          clickable: true,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        widget.comment.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Style.buttonBlue,
                                            fontSize: 18),
                                      ),
                                      NameTextAsync(
                                        widget.comment.createdBy,
                                        TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                        prefix: "",
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 15, top: 2),
                    child: Text(
                      "Em " + Helper.convertToDMYString(widget.comment.date),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text: widget.comment.description,
                      linkStyle: const TextStyle(color: Colors.blue),
                      humanize: true,
                    ),
                  ),
                  widget.isSecondLevel
                      ? Container()
                      : Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            childrenCount != 0
                                ? GestureDetector(
                                    child: Text(showChildren
                                        ? "Ocultar respostas"
                                        : "Ver Respostas ($childrenCount)"),
                                    onTap: () => setState(
                                        () => showChildren = !showChildren),
                                  )
                                : Container(),
                            SizedBox(width: 12),
                            GestureDetector(
                              child: Text("Responder"),
                              onTap: _answerComment,
                            ),
                            SizedBox(width: 16)
                          ],
                        ),
                  showChildren
                      ? StreamBuilder<QuerySnapshot>(
                          stream: widget.comment.reference
                              .collection(ForumComment.collectionName)
                              .orderBy("data", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return LinearProgressIndicator();
                            return _buildList(context, snapshot.data.documents);
                          },
                        )
                      : Container(),
                ],
              ),
              onLongPress: () =>
                  MyApp.isLabDis() || MyApp.userId() == widget.comment.createdBy
                      ? _deleteCommentConfirmation(widget.comment)
                      : null),
        ),
        showChildren ? Container() : myDivider(),
      ],
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [const SizedBox(height: 4), myDivider()]..addAll(snapshot
          .map((data) => Container(
                color: Colors.black12,
//                child: CommentListItem(
//                  ForumComment.fromMap(data.data, reference: data.reference),
//                  isSecondLevel: true,
//                ),
                child: _SecondLevelComment(
                    ForumComment.fromMap(data.data, reference: data.reference)),
              ))
          .toList()),
    );
  }

  void _answerComment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForumCommentForm(
            widget.comment.reference.collection(ForumComment.collectionName)),
      ),
    );
  }

  _deleteCommentConfirmation(ForumComment comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Comentário'),
          content: Text('Deseja realmente excluir este comentário ?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Não'),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text('Sim'),
              onPressed: () {
                comment.deleteComment();
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}

class _SecondLevelComment extends StatelessWidget {
  final ForumComment comment;
  _SecondLevelComment(this.comment);
  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key(comment.reference.documentID),
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
          child: GestureDetector(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatarAsync(
                        comment.createdBy,
                        radius: 23,
                        clickable: true,
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
                                      comment.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Style.buttonBlue,
                                          fontSize: 18),
                                    ),
                                    NameTextAsync(
                                      comment.createdBy,
                                      TextStyle(
                                          color: Colors.black54, fontSize: 14),
                                      prefix: "",
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      "Resposta em " + Helper.convertToDMYString(comment.date),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          await launch(link.url);
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      text: comment.description,
                      linkStyle: const TextStyle(color: Colors.blue),
                      humanize: true,
                    ),
                  )
                ],
              ),
              onLongPress: () =>
                  MyApp.isLabDis() || MyApp.userId() == comment.createdBy
                      ? _deleteCommentConfirmation(context, comment)
                      : null),
        ),
        myDivider(),
      ],
    );
  }

  _deleteCommentConfirmation(BuildContext context, ForumComment comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Comentário'),
          content: Text('Deseja realmente excluir este comentário ?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Não'),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text('Sim'),
              onPressed: () {
                comment.deleteComment();
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}

Widget myDivider() {
  return const Padding(
    padding: EdgeInsets.only(left: 16, right: 16),
    child: Divider(
      height: 0,
      color: Colors.black54,
    ),
  );
}
