import 'package:cloud_firestore/cloud_firestore.dart';

/// Se for UserType.person, é da classe usuario.
/// Se for UserType.institution, é da classe Instituicao.
enum UserType { person, institution }

class Occupation {
  static const String bolsista = "Bolsista";
  static const String professor = "Professor";
  static const String discente = "Discente";
  static const String laboratorio = "Laboratório";
  static const String empreendedor = "Empreendedor";
  static const String incubadora = "Incubadora";
  static const String aluno = "Aluno";
  static const String escola = "Escola";
  static const String outra = "Outra";

  static List<String> all = []
    ..add(bolsista)
    ..add(professor)
    ..add(laboratorio)
    ..add(empreendedor)
    ..add(incubadora)
    ..add(aluno)
    ..add(escola)
    ..add(outra);
}


class User {

  static final String collectionName = 'usuario';

  String name;
  String email;
  String description;
  String site;
  String facebook;
  String idInstitution;
  /// Se for TipoUsuario.pessoa, é da classe usuario.
  /// Se for TipoUsuario.instituicao, é da classe Instituicao.
  UserType type;
  String occupation;
  int active;

  DocumentReference reference;

  User({this.name, this.email, this.description='', this.site='', this.facebook='',
    this.occupation='', this.idInstitution='', this.type: UserType.person,
    this.active: 0, this.reference});

  User.fromMap(Map<String, dynamic> map, {this.reference})
      : name = map['nome'] ?? '',
        email = map['email'] ?? '',
        description = map['descricao'] ?? '',
        site = map['site'] ?? '',
        facebook = map['facebook'] ?? '',
        idInstitution = map['instituicaoId'] ?? '',
        type = UserType.values[map['tipo']],
        occupation = map['ocupacao'] ?? '',
        active = map['ativo'] ?? 0;

  Map<String, dynamic> toJson() =>
      {
        'nome': name ?? '',
        'email': email ?? '',
        'descricao': description ?? '',
        'site': site ?? '',
        'facebook': facebook ?? '',
        'instituicaoId': idInstitution ?? '',
        'tipo': type.index ?? '',
        'ocupacao': occupation ?? '',
        'ativo': active ?? 0,
      };

  bool isActive() => this.active == 1;
}