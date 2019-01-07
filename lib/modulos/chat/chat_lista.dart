import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/chat/chat.dart';
import 'package:redesign/modulos/chat/chat_tela.dart';
import 'package:redesign/modulos/chat/mensagem.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/dados_asincronos.dart';
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
      title: "Mensagens",
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

        if(querySnapshotData[0].documents.length == 0)
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Comece uma conversa através de outro perfil!"),
            ],
          );

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

    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: CircleAvatarAsync(chat.idOutroUsuario(), radius: 23.0),
          title: _TileContent(chat),
          onTap: () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatTela(chat),
                ),
              ),
        ),
        Divider(color: Colors.black45, height: 20,),
      ],
    );
  }
}

class _TileContent extends StatefulWidget {
  final Chat chat;

  _TileContent(this.chat);

  @override
  _TileContentState createState() {
    return new _TileContentState(chat);
  }
}

class _TileContentState extends State<_TileContent> {
  String ultimaMsg = "";
  String ultimaMsgHora = "";
  Color color = Colors.black45;
  FontWeight weight = FontWeight.w400;

  final Chat chat;
  _TileContentState(this.chat){
    chat.reference.collection(Mensagem.collectionName)
        .orderBy('data', descending: true).limit(1)
        .snapshots()
        // O meodo listen executa da primeira vez e a cada alteração das
        // mensagens. Se receber algo ou enviar algo, muda na interface.
        .listen((snapshot){
          if(snapshot.documents.length > 0){
            Mensagem msg = Mensagem.fromMap(snapshot.documents[0].data,
                reference: snapshot.documents[0].reference);
            setState(() {
              ultimaMsg = msg.descricao;
              ultimaMsgHora = msg.data.hour.toString() + ":" + msg.data.minute.toString();

              if(msg.criadaPor != MeuApp.userId() && !msg.lida){
                color = Tema.primaryColor;
                weight = FontWeight.w600;
              } else {
                color = Colors.black45;
                weight = FontWeight.w400;
              }
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    //TODO ajustar pra cor mudar se tiver mensagem nova (6/1/19)
                    child: NomeTextAsync(
                      chat.idOutroUsuario(),
                      TextStyle(
                        color: Colors.black54,
                      ),
                      prefixo: "",
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 10),
                    child: Text(ultimaMsgHora,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: weight,
                      ),
                    ),
                  ),
                ],
              ),
              Text(ultimaMsg,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: weight,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54,),
      ],
    );
  }
}