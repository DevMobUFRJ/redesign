import 'package:redesign/modulos/usuario/usuario.dart';

class Instituicao extends Usuario {

  String endereco;
  String cidade;
  double lat;
  double lng;

  Instituicao({nome, email, descricao, site, facebook, ocupacao, foto, this.endereco, this.cidade, this.lat, this.lng, reference}) :
    super(nome: nome, email: email, descricao: descricao, site: site,
        facebook: facebook, ocupacao: ocupacao, foto: foto, reference: reference,
        instituicaoId: null, tipo: TipoUsuario.instituicao);

  @override
  Instituicao.fromMap(Map<String, dynamic> map, {reference}) :
    super(nome: map['nome'] , email: map['email'], descricao: map['descricao'],
        site: map['site'], facebook: map['facebook'], ocupacao: map['ocupacao'],
        foto: map['foto'], tipo: TipoUsuario.instituicao, reference: reference)
  {
    endereco = map['endereco'];
    cidade = map['cidade'];
    lat = map['lat'];
    lng = map['lng'];
  }

  @override
  Map<String, dynamic> toJson() =>
    {
      'nome': nome ?? '',
      'email': email ?? '',
      'descricao': descricao ?? '',
      'site': site ?? '',
      'facebook': facebook ?? '',
      'tipo': tipo.index ?? '',
      'ocupacao': ocupacao ?? '',
      'foto': foto ?? '',
      'endereco': endereco ?? '',
      'cidade': cidade ?? '',
      'lat': lat ?? 0,
      'lng': lng ?? 0,
    };
}