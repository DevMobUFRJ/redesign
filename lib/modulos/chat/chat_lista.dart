import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/modulos/chat/chat.dart';
import 'package:redesign/modulos/chat/chat_tela.dart';
import 'package:redesign/modulos/chat/mensagem.dart';
import 'package:redesign/modulos/usuario/user.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/dados_asincronos.dart';
import 'package:redesign/widgets/base_screen.dart';

class ChatLista extends StatefulWidget {
  @override
  ChatListaState createState() => ChatListaState();
}

class ChatListaState extends State<ChatLista> {
  bool buscando = false;
  TextEditingController _buscaController = TextEditingController();
  String busca = "";

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
            onPressed: () => alternarBusca(),
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
            buscando
                ? Container(
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: ShapeDecoration(shape: StadiumBorder()),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          onChanged: textoBuscaMudou,
                          controller: _buscaController,
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

    return _TileContent(chat, this, busca);
  }

  alternarBusca() {
    setState(() {
      buscando = !buscando;
    });
    if (!buscando) {
      _buscaController.text = "";
      textoBuscaMudou("");
    }
  }

  textoBuscaMudou(String texto) {
    if(busca != texto.toLowerCase()) {
      setState(() {
        busca = texto.toLowerCase();
      });
    }
  }
}

class _TileContent extends StatefulWidget {
  final Chat chat;
  final ChatListaState parent;
  final String busca;

  _TileContent(this.chat, this.parent, this.busca)
      : super(key: Key(chat.reference.documentID));

  @override
  _TileContentState createState() => _TileContentState();
}

class _TileContentState extends State<_TileContent> {
  User usuario;
  String ultimaMsg = "";
  String ultimaMsgHora = "";
  Color color = Colors.black45;
  FontWeight weight = FontWeight.w400;

  _TileContentState(){
    print("Tile state!");
  }

  @override
  void initState() {
    super.initState();
    widget.chat.reference
        .collection(Mensagem.collectionName)
        .orderBy('data', descending: true)
        .limit(1)
        .snapshots()
        // O meodo listen executa da primeira vez e a cada alteração das
        // mensagens. Se receber algo ou enviar algo, muda na interface.
        .listen((snapshot) {
      if (snapshot.documents.length > 0) {
        Mensagem msg = Mensagem.fromMap(snapshot.documents[0].data,
            reference: snapshot.documents[0].reference);
        setState(() {
          ultimaMsg = msg.descricao;
          ultimaMsgHora = msg.horario();

          if (msg.criadaPor != MyApp.userId() && !msg.lida) {
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
        .document(widget.chat.idOutroUsuario())
        .get()
        .then((u) {
      if(this.mounted)
        setState(() {
          usuario = User.fromMap(u.data, reference: u.reference);
        });
    }).catchError((e){});
  }

  @override
  Widget build(BuildContext context) {
    // Esconde o item da lista até ter o nome. Causa certo delay pra mostrar,
    // mas não fica ruim igual quando o nome aparece depois do resto.
    if(usuario == null)
      return Container(key: ValueKey(widget.chat.reference.documentID + "fulltile"));

    if (usuario != null && widget.busca.isNotEmpty) {
      if (!usuario.name.toLowerCase().contains(widget.busca))
        return Container(key: ValueKey(widget.chat.reference.documentID + "fulltile"));
    }

    return Column(
      key: ValueKey(widget.chat.reference.documentID + "fulltile"),
      children: <Widget>[
        ListTile(
          key: ValueKey(widget.chat.reference.documentID + "tile"),
          contentPadding: EdgeInsets.all(0),
          leading: CircleAvatarAsync(widget.chat.idOutroUsuario(), radius: 23.0),
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
                              usuario.name,
                              style: TextStyle(
                                color: color,
                                fontWeight: weight,
                              ),
                            )
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, right: 10),
                            child: Text(
                              ultimaMsgHora,
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
                        ultimaMsg,
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
              builder: (context) => ChatTela(widget.chat, outroUsuario: usuario,),
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
