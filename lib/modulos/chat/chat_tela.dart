import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/modulos/chat/chat.dart';
import 'package:redesign/modulos/chat/mensagem.dart';
import 'package:redesign/modulos/usuario/institution.dart';
import 'package:redesign/modulos/usuario/user.dart';
import 'package:redesign/services/helper.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/dados_asincronos.dart';
import 'package:redesign/widgets/base_screen.dart';

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
  final User outroUsuario;
  final Chat chat;

  ChatTela(this.chat, {this.outroUsuario});

  @override
  _ChatTelaState createState() => _ChatTelaState(chat, outroUsuario);
}

class _ChatTelaState extends State<ChatTela> {
  User usuario;
  TextEditingController _controller = TextEditingController();
  CollectionReference _mensagensReference;
  Chat _chat;
  bool ehChatNovo = false;

  _ChatTelaState(this._chat, this.usuario){
    if(!temChat() && usuario != null) {
      _chat = Chat(MyApp.userId(), usuario.reference.documentID);
      encontraChat();
    } else {
      _mensagensReference = _chat.reference.collection(Mensagem.collectionName);
      Firestore.instance.collection(User.collectionName)
          .document(_chat.idOutroUsuario()).get().then(setUsuario);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!temChat()){
      return BaseScreen(
        title: usuario.name,
        body: LinearProgressIndicator(),
      );
    }

    return BaseScreen(
      title: usuario != null ? usuario.name : "",
      bodyPadding: EdgeInsets.only(top: 4),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 1, top: 0),
              child: _ListaMensagens(this),
            ),
          ),
          Container(
            color: Style.primaryColor,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    decoration: ShapeDecoration(shape: StadiumBorder(), color: Colors.white),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        hintText: "Digite uma mensagem",
                        border: InputBorder.none,
                      ),
                      inputFormatters: [LengthLimitingTextInputFormatter(500)],
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: ShapeDecoration(shape: CircleBorder(), color: Style.lightGrey),
                  width: 32,
                  height: 32,
                  child: GestureDetector(
                    child: Icon(Icons.arrow_forward, color: Style.primaryColor),
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
    Firestore.instance.collection(Chat.collectionName)
        .document(_chat.getIdReferencia()).get()
        .then(encontrouChat)
        .catchError((e){});
  }

  encontrouChat(DocumentSnapshot doc){
    if(doc.exists){
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
    if(_controller.text == null || _controller.text.trim().isEmpty) return;

    if(ehChatNovo){
      setState(() {
        _chat.reference.setData(_chat.toJson());
        _mensagensReference = _chat.reference.collection(Mensagem.collectionName);
        ehChatNovo = false;
      });
    }
    Mensagem novaMensagem = Mensagem(descricao: _controller.text, criadaPor: MyApp.userId(), data: DateTime.now());
    _mensagensReference.add(novaMensagem.toJson());
    _chat.reference.updateData({'ultima_mensagem': novaMensagem.data.toIso8601String()});
    _controller.text = "";
  }

  setUsuario(DocumentSnapshot doc){
    setState(() {
      if(doc.data['tipo'] == UserType.institution) {
        usuario = Institution.fromMap(doc.data, reference: doc.reference);
      } else {
        usuario = User.fromMap(doc.data, reference: doc.reference);
      }
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
  String ultimaData = "";

  __ListaMensagensState(this.parent);

  @override
  Widget build(BuildContext context) {
    if(this.parent._mensagensReference == null || this.parent.ehChatNovo){
      return Container();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: this.parent._mensagensReference
          .orderBy("data", descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      reverse: true,
      children: snapshot.map((data){
        bool dataMudou = false;
        if(Helper.convertToDMYString(DateTime.tryParse(data.data['data'])) != ultimaData){
          ultimaData = Helper.convertToDMYString(DateTime.tryParse(data.data['data']));
          dataMudou = true;
        }
        return Column(
          children: <Widget>[
            dataMudou ?
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(ultimaData,
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 12.0,
                ),
              )
            ) : Container(),
            _buildListItem(context, data),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    Mensagem mensagem = Mensagem.fromMap(data.data, reference: data.reference);
    bool propria = mensagem.criadaPor == MyApp.userId();

    if(propria) {
      return Container(
        key: ValueKey(data.documentID),
        padding: EdgeInsets.only(left: 60, bottom: 6, top: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                      color: Style.primaryColor,
                    ),
                    child: Text(
                      mensagem.descricao,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Ao carregar a mensagem, marca que já foi lida.
      mensagem.reference.updateData({'lida': true});

      return Container(
        key: ValueKey(data.documentID),
        padding: EdgeInsets.only(right: 60, bottom: 6, top: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: CircleAvatarAsync(mensagem.criadaPor, radius: 18, clicavel: true,),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                      color: Style.darkBackground,
                    ),
                    child: Text(
                      mensagem.descricao,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}