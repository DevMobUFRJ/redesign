import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  static const String collectionName = "chat";

  String user1;
  String user2;

  String docId;
  DocumentReference reference;

  /// Recebe IDs de 2 usuários, não importa a ordem, o construtor
  /// colocará o menor primeiro, mantendo sempre a ordem.
  Chat(id1, id2, {this.reference})
  {
    if(id1.hashCode <= id2.hashCode){
      user1 = id1;
      user2 = id2;
    } else {
      user1 = id2;
      user2 = id1;
    }
    atualizarDocId();
  }

  Chat.fromMap(Map<String, dynamic> data, {this.reference}) :
        user1 = data['user1'], user2 = data['user2']
  {
    atualizarDocId();
  }

  void atualizarDocId(){
    if(user1.hashCode <= user2.hashCode){
      docId = user1 + "-" + user2;
    } else {
      docId = user2 + "-" + user1;
    }
  }

  Map<String, dynamic> toJson() =>
      {
        'user1': user1,
        'user2': user2
      };

}