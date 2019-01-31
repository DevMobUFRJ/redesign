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
}