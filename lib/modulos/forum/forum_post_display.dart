import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/forum/forum_comment.dart';
import 'package:redesign/modulos/forum/forum_comment_form.dart';
import 'package:redesign/modulos/forum/forum_post.dart';
import 'package:redesign/services/helper.dart';
import 'package:redesign/widgets/standard_button.dart';
import 'package:redesign/widgets/async_data.dart';
import 'package:redesign/widgets/forum_base_screen_post.dart';

class ForumPostDisplay extends StatefulWidget {
  final ForumPost post;

  ForumPostDisplay(this.post);

  @override
  ForumPostDisplayState createState() => ForumPostDisplayState(post);
}

class ForumPostDisplayState extends State<ForumPostDisplay> {
  final ForumPost post;

  ForumPostDisplayState(this.post);

  @override
  Widget build(BuildContext context) {
    return ForumBaseScreen(
      title: post.title,
      body: Column(
        children: <Widget>[
          Container(
            color: Style.darkBackground,
            padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 10),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatarAsync(
                      post.createdBy,
                      radius: 26,
                      clickable: true,
                    ),
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
                                    post.title,
                                    style: TextStyle(
                                      color: Style.primaryColorLighter,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    softWrap: false,
                                    overflow: TextOverflow.clip,
                                  ),
                                  NameTextAsync(
                                    post.createdBy,
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
          _CommentsList(
              post.reference.collection(ForumComment.collectionName), post),
        ],
      ),
    );
  }
}

class _CommentsList extends StatefulWidget {
  final CollectionReference reference;
  final ForumPost post;

  _CommentsList(this.reference, this.post);

  @override
  _CommentsListState createState() => _CommentsListState(reference, post);
}

class _CommentsListState extends State<_CommentsList> {
  CollectionReference reference;
  final ForumPost post;

  _CommentsListState(this.reference, this.post);

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
                post.description,
                style: TextStyle(color: Colors.white),
              ),
            )
          ]
                ..addAll(snapshot
                    .map((data) => _buildListItem(context, data))
                    .toList())
                // Padding extra no final da lista
                ..add(Container(
                  padding: EdgeInsets.only(bottom: 60.0),
                ))),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: StandardButton("Contribuir", addComment,
                Style.main.primaryColor, Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    ForumComment comment =
        ForumComment.fromMap(data.data, reference: data.reference);
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
                  )),
            ],
          ),
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 15, bottom: 5),
              child: Text(
                "Em " + Helper.convertToDMYString(comment.date),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Text(
                comment.description,
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

  addComment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForumCommentForm(
            post.reference.collection(ForumComment.collectionName)),
      ),
    );
  }
}
