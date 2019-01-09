import 'dart:convert';

/// Uma classe bem simples que salva a classe/tipo do item favoritado,
/// e o ID dele do firebase. Devemos manter, então, uma List<Favorito> no
/// usuário para salvar todos os favoritos dele, e em cada activity procurar
/// nessa lista se o elemento é ou não favorito dele.
class Favorito {
  static const String collectionName = "favorito";
  String id;
  String classe;

  Favorito({this.id, this.classe});

  Favorito.fromMap(Map<String, dynamic> map) :
      id = map['id'], classe = map['classe'];

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'classe': classe
      };


//  static bool ocupado = false;
//  static void alternaFavorito(String id, String classe, VoidCallback) async {
//    if(ocupado) return null;
//    ocupado = true;
//    MeuApp.getReferenciaUsuario().collection(Favorito.collectionName)
//        .where("id", isEqualTo: evento.reference.documentID)
//        .snapshots().first.then((QuerySnapshot vazio){
//      if(vazio.documents.length == 0) {
//        MeuApp.getReferenciaUsuario().collection(Favorito.collectionName)
//            .add((new Favorito(id: evento.reference.documentID,
//            classe: evento.runtimeType.toString()).toJson()))
//            .then((v){ print("Adicionaro"); ocupado = false; }).catchError((e) => print(e));
//      } else {
//        vazio.documents.first.reference.delete()
//            .then((v){ print("Removido"); ocupado = false;}).catchError((e) => print(e));
//      }
//    }).catchError((e) => print(e));
//  }
}