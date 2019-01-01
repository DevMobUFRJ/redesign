import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/chat/chat.dart';
import 'package:redesign/modulos/chat/mensagem.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/tela_base.dart';

/// O elemento chat OU usuário podem ser null.
/// Se usuário for null, o chat não deve ser null, e o usuário será
/// automáticamente deduzido a partir do chat.
/// Se chat for null, usuário não pode ser null, e o chat será encontrado
/// para aquele usuário. Se nao houver, será criado um novo chat.
///
/// USO: É ideal passar um chat caso venha da lista de mensagens,
/// e passar um usuário com chat null se vier do perfil do usuário,
/// pois nesse segundo cenário não se sabe se já existe um chat.
class ChatTela extends StatefulWidget {
  final Usuario outroUsuario;
  final Chat chat;

  ChatTela(this.chat, {this.outroUsuario});

  @override
  _ChatTelaState createState() => _ChatTelaState(chat, outroUsuario);
}

class _ChatTelaState extends State<ChatTela> {
  Usuario usuario;
  TextEditingController _controller = TextEditingController();
  CollectionReference _mensagensReference;
  Chat _chat;
  bool ehChatNovo = false;

  _ChatTelaState(this._chat, this.usuario){
    if(!temChat() && usuario != null) {
      _chat = Chat(MeuApp.userId(), usuario.reference.documentID);
      encontraChat();
    } else {
      _mensagensReference = _chat.reference.collection(Mensagem.collectionName);
      Firestore.instance.collection(Usuario.collectionName)
          .document(_chat.idOutroUsuario()).get().then(setUsuario);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!temChat()){
      return TelaBase(
        title: usuario.nome,
        body: CircularProgressIndicator(),
      );
    }

    return TelaBase(
      title: usuario != null ? usuario.nome : "",
      body: Column(
        children: <Widget>[
          Expanded(
            child: _ListaMensagens(this),
          ),
          Container(
            color: Tema.primaryColor,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 10 ),
                    decoration: ShapeDecoration(shape: StadiumBorder(), color: Colors.white),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        hintText: "Digite uma mensagem",
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: ShapeDecoration(shape: CircleBorder(), color: Tema.cinzaClaro),
                  width: 32,
                  height: 32,
                  child: GestureDetector(
                    child: Icon(Icons.arrow_forward, color: Tema.primaryColor),
                    onTap: enviarMensagem,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool temChat(){
    return _chat != null && _chat.reference != null;
  }

  encontraChat(){
    print("Encontra chat");
    Firestore.instance.collection(Chat.collectionName)
        .document(_chat.getIdReferencia()).get()
        .then(encontrouChat)
        .catchError((e) => print(e));
  }

  encontrouChat(DocumentSnapshot doc){
    if(doc.exists){
      print("Chat existe");
      setState(() {
        _chat.reference = doc.reference;
        _mensagensReference = doc.reference.collection(Mensagem.collectionName);
      });
    } else {
      setState(() {
        _chat.reference = doc.reference;
        ehChatNovo = true;
      });
    }
  }

  enviarMensagem(){
    if(ehChatNovo){
      setState(() {
        _chat.reference.setData(_chat.toJson());
        _mensagensReference = _chat.reference.collection(Mensagem.collectionName);
        ehChatNovo = false;
      });
    }
    Mensagem novaMensagem = Mensagem(descricao: _controller.text, criadaPor: MeuApp.userId(), data: DateTime.now());
    _mensagensReference.add(novaMensagem.toJson());
    _controller.text = "";
  }

  setUsuario(DocumentSnapshot doc){
    setState(() {
      usuario = Usuario.fromMap(doc.data, reference: doc.reference);
    });
  }
}


class _ListaMensagens extends StatefulWidget {
  final _ChatTelaState parent;

  _ListaMensagens(this.parent);

  @override
  __ListaMensagensState createState() => __ListaMensagensState(parent);
}

class __ListaMensagensState extends State<_ListaMensagens> {
  final _ChatTelaState parent;

  __ListaMensagensState(this.parent);

  @override
  Widget build(BuildContext context) {
    if(this.parent._mensagensReference == null || this.parent.ehChatNovo){
      return Container();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: this.parent._mensagensReference
          .orderBy("data", descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      reverse: true,
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    Mensagem mensagem = Mensagem.fromMap(data.data, reference: data.reference);
    bool propria = mensagem.criadaPor == MeuApp.userId();

    return Container(
      key: ValueKey(data.documentID),
      padding: propria ? EdgeInsets.only(left: 50, bottom: 5, top: 5) : EdgeInsets.only(right: 50, bottom: 5, top: 5),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
            title: Text(mensagem.descricao),
          )
      ),
    );
  }
}