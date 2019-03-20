import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/forum/forum_post_list.dart';
import 'package:redesign/modulos/forum/forum_topic.dart';
import 'package:redesign/widgets/simple_list_item.dart';
import 'package:redesign/widgets/base_screen.dart';

class ForumTopicList extends StatefulWidget {

  @override
  ForumTopicListState createState() => ForumTopicListState();
}

class ForumTopicListState extends State<ForumTopicList> {
  bool searching = false;
  TextEditingController _searchController = TextEditingController();
  String search = "";

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Fórum",
      body: _buildBody(context),
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
      stream: Firestore.instance.collection(ForumTopic.collectionName)
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
              children: [
                searching ?
                Container(
                  margin: EdgeInsets.only(bottom: 5),
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
                  )
                )
                : Container(),
              ]
              ..addAll(snapshot.map((data) => _buildListItem(context, data)).toList()),
            ),
          ),
        ]
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    ForumTopic topic = ForumTopic.fromMap(data.data, reference: data.reference);

    if(!topic.title.toLowerCase().contains(search))
      return Container();

    return SimpleListItem(
      topic.title,
      () => tapItem(topic),
      key: ValueKey(data.documentID)
    );
  }

  tapItem(ForumTopic topic){
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => ForumPostList(topic),),
    );
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