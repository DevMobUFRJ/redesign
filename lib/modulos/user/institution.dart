import 'package:redesign/modulos/user/user.dart';

class Institution extends User {

  String address;
  String city;
  double lat;
  double lng;

  Institution({name, email, description='', site='', facebook='', occupation='', active=0,
    this.address='', this.city='', this.lat=0.0, this.lng=0.0, reference}) :
    super(name: name, email: email, description: description, site: site,
        facebook: facebook, occupation: occupation, reference: reference,
        idInstitution: null, type: UserType.institution, active: active);

  @override
  Institution.fromMap(Map<String, dynamic> map, {reference}) :
    super(name: map['nome'] , email: map['email'], description: map['descricao'],
        site: map['site'], facebook: map['facebook'], occupation: map['ocupacao'],
        type: UserType.values[map['tipo']], active: map['ativo'],
          reference: reference)
  {
    address = map['endereco'];
    city = map['cidade'];
    lat = (map['lat'] as num).toDouble();
    lng = (map['lng'] as num).toDouble();
  }

  @override
  Map<String, dynamic> toJson() =>
    {
      'nome': name ?? '',
      'email': email ?? '',
      'descricao': description ?? '',
      'site': site ?? '',
      'facebook': facebook ?? '',
      'tipo': type.index ?? '',
      'ocupacao': occupation ?? '',
      'endereco': address ?? '',
      'ativo': active ?? 0,
      'cidade': city ?? '',
      'lat': lat ?? 0.0,
      'lng': lng ?? 0.0,
    };

  //Métodos necessários para fazer o dropdown funcionar
  bool operator ==(o) => o is Institution && name == o.name && email == o.email;
  int get hashCode => name.hashCode + email.hashCode;
}