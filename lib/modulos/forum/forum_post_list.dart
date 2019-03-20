import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/forum/forum_post.dart';
import 'package:redesign/modulos/forum/forum_post_display.dart';
import 'package:redesign/modulos/forum/forum_post_form.dart';
import 'package:redesign/modulos/forum/forum_topic.dart';
import 'package:redesign/widgets/async_data.dart';
import 'package:redesign/widgets/base_screen.dart';

class ForumPostList extends StatefulWidget {
  final ForumTopic topic;

  ForumPostList(this.topic);

  @override
  ForumPostListState createState() => ForumPostListState(topic);
}

class ForumPostListState extends State<ForumPostList> {
  bool searching = false;
  TextEditingController _searchController = TextEditingController();
  String search = "";
  
  ForumTopic topic;

  ForumPostListState(this.topic);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: topic.title,
      body: _buildBody(context),
      fab: FloatingActionButton(
        onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForumPostForm(topic),
              ),
            ),
        child: Icon(Icons.add),
        backgroundColor: Style.main.primaryColor,
      ),
      actions: <IconButton>[
        IconButton(
          icon: Icon(
              Icons.search,
              color: Colors.white
          ),
          onPressed: () => toggleSearch(),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(ForumPost.collectionName)
          .where("temaId", isEqualTo: topic.reference.documentID)
          .orderBy("data", descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        if(snapshot.data.documents.length == 0)
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Ainda não há problemas sobre esse tema"),
            ],
          );

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(children: [
      Expanded(
        child: ListView(
          children: [
            searching ?
            Container(
              margin: EdgeInsets.only(bottom: 15),
              decoration: ShapeDecoration(shape: StadiumBorder()),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: searchTextChanged,
                      controller: _searchController,
                      cursorColor: Style.lightGrey,
                      decoration: InputDecoration(
                        hintText: "Buscar",
                        prefixIcon: Icon(Icons.search, color: Style.primaryColor)
                      ),
                    ),
                  ),
                ]
              ),
            )
            : Container(),
          ]..addAll(snapshot.map((data) => _buildListItem(context, data)).toList()),
        ),
      ),
    ]);
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    ForumPost post = ForumPost.fromMap(data.data, reference: data.reference);
    
    if(!post.title.toLowerCase().contains(search)
      && !post.description.toLowerCase().contains(search))
      return Container();
    
    return _PostItem(post);
  }
  
  toggleSearch(){
    setState((){
      searching = !searching;
    });
    
    if(!searching) {
      _searchController.text = "";
      searchTextChanged("");
    }
  }

  searchTextChanged(String text){
    setState(() {
      search = text.toLowerCase();
    });
  }
}

class _PostItem extends StatefulWidget {
  final ForumPost post;

  _PostItem(this.post) : super(key: Key(post.reference.documentID));

  @override
  _PostState createState() => _PostState(post);
}

class _PostState extends State<_PostItem> {
  final ForumPost post;

  _PostState(this.post);

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
                CircleAvatarAsync(post.createdBy, radius: 23,),
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
                                post.title,
                                style: TextStyle(
                                    color: Style.buttonBlue, fontSize: 18),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                softWrap: false,
                              ),
                              NameTextAsync(
                                post.createdBy,
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
                          color: Style.buttonBlue,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4),
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
          builder: (context) => ForumPostDisplay(post),
        ),
      ),
    );
  }

}
