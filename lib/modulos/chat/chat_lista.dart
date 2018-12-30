import 'dart:async';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/chat/chat.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/tela_base.dart';

class ChatLista extends StatefulWidget {
  @override
  ChatListaState createState() => ChatListaState();
}

class ChatListaState extends State<ChatLista> {
  Stream<List<QuerySnapshot>> getData() {
    Stream stream1 = Firestore.instance.collection(Chat.collectionName)
                      .where('user1', isEqualTo: MeuApp.userId()).snapshots();
    Stream stream2 = Firestore.instance.collection(Chat.collectionName)
                      .where('user2', isEqualTo: MeuApp.userId()).snapshots();
    return StreamZip([stream1, stream2]);
  }

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: "Conversas",
      body: _buildBody(context),
    );
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
        List<QuerySnapshot> querySnapshotData =  snapshot.data.toList();
        querySnapshotData[0].documents.addAll(querySnapshotData[1].documents);
        return _buildList(context, querySnapshotData[0].documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(
        children: [
          Expanded(
            child:  ListView(
              children: snapshot.map((data) => _buildListItem(context, data)).toList(),
            ),
          ),
        ]
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    Chat chat = Chat.fromMap(data.data, reference: data.reference);

    return Container(
      key: ValueKey(data.documentID),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
            title: Text(chat.docId),
            onTap: (){ print(chat.toJson()); },
          )
      ),
    );
  }
}