import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/chat/chat.dart';
import 'package:redesign/modulos/chat/chat_screen.dart';
import 'package:redesign/modulos/chat/message.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/dados_asincronos.dart';
import 'package:redesign/widgets/base_screen.dart';

class ChatList extends StatefulWidget {
  @override
  ChatListState createState() => ChatListState();
}

class ChatListState extends State<ChatList> {
  bool searching = false;
  TextEditingController _searchController = TextEditingController();
  String search = "";

  Stream<List<QuerySnapshot>> getData() {
    Stream stream1 = Firestore.instance
        .collection(Chat.collectionName)
        .where('user1', isEqualTo: MyApp.userId())
        .snapshots();
    Stream stream2 = Firestore.instance
        .collection(Chat.collectionName)
        .where('user2', isEqualTo: MyApp.userId())
        .snapshots();
    return StreamZip([stream1, stream2]);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: "Mensagens",
        body: _buildBody(context),
        actions: <IconButton>[
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () => toggleSearch(),
          ),
        ]);
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<List<QuerySnapshot>>(
      stream: getData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        // Isso aqui é um esquema pra juntar dois queries diferentes do firebase
        // em um só. A gente faz o merge deles no método getData, então é uma
        // lista com 2 posições, aqui a gente copia da segunda pra primeira,
        // e usa só a primeira.
        List<QuerySnapshot> querySnapshotData = snapshot.data.toList();
        querySnapshotData[1].documents.forEach((d){
          if(!querySnapshotData[0].documents.contains(d)){
            querySnapshotData[0].documents.add(d);
          }
        });

        if (querySnapshotData[0].documents.length == 0)
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Comece uma conversa através de outro perfil!"),
            ],
          );

        querySnapshotData[0].documents.sort( (a, b){
          return b.data['ultima_mensagem'].toString().compareTo(a.data['ultima_mensagem']);
        });

        return _buildList(context, querySnapshotData[0].documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(children: [
      Expanded(
        child: ListView(
          children: [
            searching
                ? Container(
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: ShapeDecoration(shape: StadiumBorder()),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          onChanged: didChangeTextSearch,
                          controller: _searchController,
                          cursorColor: Style.lightGrey,
                          decoration: InputDecoration(
                              hintText: "Buscar",
                              prefixIcon:
                                  Icon(Icons.search, color: Style.primaryColor)),
                        ),
                      ),
                    ]))
                : Container(),
          ]..addAll(
              snapshot.map((data) => _buildListItem(context, data)).toList()),
        ),
      ),
    ]);
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    Chat chat = Chat.fromMap(data.data, reference: data.reference);

    return _TileContent(chat, this, search);
  }

  toggleSearch() {
    setState(() {
      searching = !searching;
    });
    if (!searching) {
      _searchController.text = "";
      didChangeTextSearch("");
    }
  }

  didChangeTextSearch(String text) {
    if(search != text.toLowerCase()) {
      setState(() {
        search = text.toLowerCase();
      });
    }
  }
}

class _TileContent extends StatefulWidget {
  final Chat chat;
  final ChatListState parent;
  final String search;

  _TileContent(this.chat, this.parent, this.search)
      : super(key: Key(chat.reference.documentID));

  @override
  _TileContentState createState() => _TileContentState();
}

class _TileContentState extends State<_TileContent> {
  User user;
  String lastMessage = "";
  String lastMessageHour = "";
  Color color = Colors.black45;
  FontWeight weight = FontWeight.w400;

  _TileContentState(){
    print("Tile state!");
  }

  @override
  void initState() {
    super.initState();
    widget.chat.reference
        .collection(Message.collectionName)
        .orderBy('data', descending: true)
        .limit(1)
        .snapshots()
        // O meodo listen executa da primeira vez e a cada alteração das
        // mensagens. Se receber algo ou enviar algo, muda na interface.
        .listen((snapshot) {
      if (snapshot.documents.length > 0) {
        Message msg = Message.fromMap(snapshot.documents[0].data,
            reference: snapshot.documents[0].reference);
        setState(() {
          lastMessage = msg.description;
          lastMessageHour = msg.timestamp();

          if (msg.createdBy != MyApp.userId() && !msg.read) {
            color = Style.primaryColor;
            weight = FontWeight.w800;
          } else {
            color = Colors.black45;
            weight = FontWeight.w400;
          }
        });
      }
    });
    Firestore.instance
        .collection(User.collectionName)
        .document(widget.chat.otherUserId())
        .get()
        .then((u) {
      if(this.mounted)
        setState(() {
          user = User.fromMap(u.data, reference: u.reference);
        });
    }).catchError((e){});
  }

  @override
  Widget build(BuildContext context) {
    // Esconde o item da lista até ter o nome. Causa certo delay pra mostrar,
    // mas não fica ruim igual quando o nome aparece depois do resto.
    if(user == null)
      return Container(key: ValueKey(widget.chat.reference.documentID + "fulltile"));

    if (user != null && widget.search.isNotEmpty) {
      if (!user.name.toLowerCase().contains(widget.search))
        return Container(key: ValueKey(widget.chat.reference.documentID + "fulltile"));
    }

    return Column(
      key: ValueKey(widget.chat.reference.documentID + "fulltile"),
      children: <Widget>[
        ListTile(
          key: ValueKey(widget.chat.reference.documentID + "tile"),
          contentPadding: EdgeInsets.all(0),
          leading: CircleAvatarAsync(widget.chat.otherUserId(), radius: 23.0),
          title: Container(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              user.name,
                              style: TextStyle(
                                color: color,
                                fontWeight: weight,
                              ),
                            )
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, right: 10),
                            child: Text(
                              lastMessageHour,
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                                fontWeight: weight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        lastMessage,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: weight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(widget.chat, otherUser: user,),
            ),
          ),
        ),
        Divider(
          color: Colors.black45,
          height: 20,
        )
      ],
    );
  }
}
