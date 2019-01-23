import 'package:redesign/modulos/usuario/usuario.dart';

class Instituicao extends Usuario {

  String endereco;
  String cidade;
  double lat;
  double lng;

  Instituicao({nome, email, descricao='', site='', facebook='', ocupacao='', ativo=false,
    this.endereco='', this.cidade='', this.lat=0.0, this.lng=0.0, reference}) :
    super(nome: nome, email: email, descricao: descricao, site: site,
        facebook: facebook, ocupacao: ocupacao, reference: reference,
        instituicaoId: null, tipo: TipoUsuario.instituicao, ativo: ativo);

  @override
  Instituicao.fromMap(Map<String, dynamic> map, {reference}) :
    super(nome: map['nome'] , email: map['email'], descricao: map['descricao'],
        site: map['site'], facebook: map['facebook'], ocupacao: map['ocupacao'],
        tipo: TipoUsuario.values[map['tipo']], ativo: map['ativo'],
          reference: reference)
  {
    endereco = map['endereco'];
    cidade = map['cidade'];
    lat = (map['lat'] as num).toDouble();
    lng = (map['lng'] as num).toDouble();
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
      'endereco': endereco ?? '',
      'ativo': ativo ?? false,
      'cidade': cidade ?? '',
      'lat': lat ?? 0.0,
      'lng': lng ?? 0.0,
    };
}