import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redesign/services/my_app.dart';

class Chat {
  static const String collectionName = "chat";

  String user1;
  String user2;
  DateTime ultimaMensagem;

  DocumentReference reference;

  /// Recebe IDs de 2 usuários, não importa a ordem, o construtor
  /// colocará o menor primeiro, mantendo sempre a ordem.
  Chat(String id1, String id2, {this.reference})
  {
    if(id1.hashCode <= id2.hashCode){
      user1 = id1;
      user2 = id2;
    } else {
      user1 = id2;
      user2 = id1;
    }
  }

  Chat.fromMap(Map<String, dynamic> data, {this.reference}) :
      user1 = data['user1'],
      user2 = data['user2'],
      ultimaMensagem = DateTime.tryParse(data['ultima_mensagem'] ?? DateTime.now().toIso8601String());

  String getIdReferencia(){
    if(user1.hashCode <= user2.hashCode){
      return user1 + "-" + user2;
    } else {
      return user2 + "-" + user1;
    }
  }

  String idOutroUsuario(){
    if(user1 == MyApp.userId()){
      return user2;
    } else {
      return user1;
    }
  }

  Map<String, dynamic> toJson() =>
      {
        'user1': user1,
        'user2': user2,
        'ultima_mensagem': ultimaMensagem.toIso8601String(),
      };

}