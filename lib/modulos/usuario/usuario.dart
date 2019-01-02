import 'package:cloud_firestore/cloud_firestore.dart';

/// Se for TipoUsuario.pessoa, é da classe usuario.
/// Se for TipoUsuario.instituicao, é da classe Instituicao.
enum TipoUsuario { pessoa, instituicao }

class Usuario {

  static final String collectionName = 'usuario';

  String nome;
  String email;
  String descricao;
  String site;
  String facebook;
  String instituicaoId;
  /// Se for TipoUsuario.pessoa, é da classe usuario.
  /// Se for TipoUsuario.instituicao, é da classe Instituicao.
  TipoUsuario tipo;
  String ocupacao;

  DocumentReference reference;

  Usuario({this.nome, this.email, this.descricao='', this.site='', this.facebook='',
    this.ocupacao='', this.instituicaoId='', this.reference, this.tipo: TipoUsuario.pessoa});

  Usuario.fromMap(Map<String, dynamic> map, {this.reference})
      : nome = map['nome'] ?? '',
        email = map['email'] ?? '',
        descricao = map['descricao'] ?? '',
        site = map['site'] ?? '',
        facebook = map['facebook'] ?? '',
        instituicaoId = map['instituicaoId'] ?? '',
        tipo = TipoUsuario.values[map['tipo']],
        ocupacao = map['ocupacao'] ?? '';

  Map<String, dynamic> toJson() =>
      {
        'nome': nome ?? '',
        'email': email ?? '',
        'descricao': descricao ?? '',
        'site': site ?? '',
        'facebook': facebook ?? '',
        'instituicaoId': instituicaoId ?? '',
        'tipo': tipo.index ?? '',
        'ocupacao': ocupacao ?? '',
      };
}