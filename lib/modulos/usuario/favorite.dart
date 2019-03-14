/// Uma classe bem simples que salva a classe/tipo do item favoritado,
/// e o ID dele do firebase. Devemos manter, então, uma List<Favorito> no
/// usuário para salvar todos os favoritos dele, e em cada activity procurar
/// nessa lista se o elemento é ou não favorito dele.
class Favorite {
  static const String collectionName = "favorito";
  String id;
  String className;

  Favorite({this.id, this.className});

  Favorite.fromMap(Map<String, dynamic> map) :
      id = map['id'], className = map['classe'];

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'classe': className
      };
}