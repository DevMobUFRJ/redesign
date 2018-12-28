import 'package:redesign/modulos/usuario/usuario.dart';

class Instituicao extends Usuario {

  String endereco;
  String cidade;

  Instituicao({nome, email, descricao, site, facebook, ocupacao, this.endereco, this.cidade, reference}) :
    super(nome: nome, email: email, descricao: descricao, site: site,
        facebook: facebook, ocupacao: ocupacao, reference: reference,
        instituicaoId: null, tipo: TipoUsuario.instituicao);

  Instituicao.fromMap(Map<String, dynamic> map, {reference})
      : super(nome: map['nome'] , email: map['email'], descricao: map['descricao'],
      site: map['site'], facebook: map['facebook'], ocupacao: map['ocupacao'],
      tipo: TipoUsuario.instituicao, reference: reference);

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
        'cidade': cidade ?? '',
      };
}