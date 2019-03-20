import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/chat/chat.dart';
import 'package:redesign/modulos/chat/message.dart';
import 'package:redesign/modulos/user/institution.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/services/helper.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/async_data.dart';
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
class ChatScreen extends StatefulWidget {
  final User otherUser;
  final Chat chat;

  ChatScreen(this.chat, {this.otherUser});

  @override
  _ChatScreenState createState() => _ChatScreenState(chat, otherUser);
}

class _ChatScreenState extends State<ChatScreen> {
  User user;
  TextEditingController _controller = TextEditingController();
  CollectionReference _messagesReference;
  Chat _chat;
  bool isNewChat = false;

  _ChatScreenState(this._chat, this.user){
    if(!temChat() && user != null) {
      _chat = Chat(MyApp.userId(), user.reference.documentID);
      getChat();
    } else {
      _messagesReference = _chat.reference.collection(Message.collectionName);
      Firestore.instance.collection(User.collectionName)
          .document(_chat.otherUserId()).get().then(setUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!temChat()){
      return BaseScreen(
        title: user.name,
        body: LinearProgressIndicator(),
      );
    }

    return BaseScreen(
      title: user != null ? user.name : "",
      bodyPadding: EdgeInsets.only(top: 4),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 1, top: 0),
              child: _MessagesList(this),
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
                    onTap: sendMessage,
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

  getChat(){
    Firestore.instance.collection(Chat.collectionName)
        .document(_chat.getIdReference()).get()
        .then(foundChat)
        .catchError((e){});
  }

  foundChat(DocumentSnapshot doc){
    if(doc.exists){
      setState(() {
        _chat.reference = doc.reference;
        _messagesReference = doc.reference.collection(Message.collectionName);
      });
    } else {
      setState(() {
        _chat.reference = doc.reference;
        isNewChat = true;
      });
    }
  }

  sendMessage(){
    if(_controller.text == null || _controller.text.trim().isEmpty) return;

    if(isNewChat){
      setState(() {
        _chat.reference.setData(_chat.toJson());
        _messagesReference = _chat.reference.collection(Message.collectionName);
        isNewChat = false;
      });
    }
    Message newMessage = Message(description: _controller.text, createdBy: MyApp.userId(), date: DateTime.now());
    _messagesReference.add(newMessage.toJson());
    _chat.reference.updateData({'ultima_mensagem': newMessage.date.toIso8601String()});
    _controller.text = "";
  }

  setUser(DocumentSnapshot doc){
    setState(() {
      if(doc.data['tipo'] == UserType.institution) {
        user = Institution.fromMap(doc.data, reference: doc.reference);
      } else {
        user = User.fromMap(doc.data, reference: doc.reference);
      }
    });
  }
}


class _MessagesList extends StatefulWidget {
  final _ChatScreenState parent;

  _MessagesList(this.parent);

  @override
  _MessagesListState createState() => _MessagesListState(parent);
}

class _MessagesListState extends State<_MessagesList> {
  final _ChatScreenState parent;
  String lastDate = "";

  _MessagesListState(this.parent);

  @override
  Widget build(BuildContext context) {
    if(this.parent._messagesReference == null || this.parent.isNewChat){
      return Container();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: this.parent._messagesReference
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
        bool dateChanged = false;
        if(Helper.convertToDMYString(DateTime.tryParse(data.data['data'])) != lastDate){
          lastDate = Helper.convertToDMYString(DateTime.tryParse(data.data['data']));
          dateChanged = true;
        }
        return Column(
          children: <Widget>[
            dateChanged ?
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(lastDate,
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
    Message message = Message.fromMap(data.data, reference: data.reference);
    bool isUserMessage = message.createdBy == MyApp.userId();

    if(isUserMessage) {
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
                      message.description,
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
      message.reference.updateData({'lida': true});

      return Container(
        key: ValueKey(data.documentID),
        padding: EdgeInsets.only(right: 60, bottom: 6, top: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: CircleAvatarAsync(message.createdBy, radius: 18, clickable: true,),
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
                      message.description,
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