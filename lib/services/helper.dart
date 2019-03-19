import 'package:redesign/modulos/user/user.dart';

class Helper {

  static const String emailLabdis = "labdis.ufrj@gmail.com";

  /// Retorna o nome da ocupação para o tipo de instituição passada.
  /// Ocupacao secundária: Aluno, Bolsista, Estudante.
  ///
  /// Ex: Para laboratórios, retorna "Bolsista".
  /// Para Escolas, retorna "Aluno"
  static String getSecondaryOccupationToInstitution(String institutionOccupation){
    switch(institutionOccupation){
      case Occupation.incubadora:
        return "";

      case Occupation.laboratorio:
        return Occupation.bolsista;

      case Occupation.escola:
        return Occupation.aluno;

      default:
        return Occupation.bolsista;
    }
  }

  /// Retorna um titulo no plural para a instituicao.
  static String getSecondaryOccupationTitle(String institutionOccupation){
    switch(institutionOccupation){
      case Occupation.incubadora:
        return "";

      case Occupation.laboratorio:
        return "Bolsistas";

      case Occupation.escola:
        return "Alunos";

      default:
        return "Bolsistas";
    }
  }

  /// Retorna o nome da ocupação para o tipo de instituição passada.
  /// Ocupacao primária: Professor ou Empreendedor.
  ///
  /// Ex: Para laboratórios, retorna "Professor".
  /// Para Escolas, retorna "Professor"
  static String getOcupacaoPrimariaParaInstituicao(String ocupacaoInstituicao){
    switch(ocupacaoInstituicao){
      case Occupation.incubadora:
        return Occupation.empreendedor;

      case Occupation.laboratorio:
      case Occupation.escola:
        return Occupation.professor;

      default:
        return Occupation.professor;
    }
  }

  /// Retorna um titulo no plural para a instituicao.
  static String getPrimaryOccupationTitle(String institutionOccupation){
    switch(institutionOccupation){
      case Occupation.incubadora:
        return "Empreendedores";

      case Occupation.laboratorio:
      case Occupation.escola:
        return "Professores";

      default:
        return "Professores";
    }
  }

  static String convertToDMYString(DateTime d){
    try{
      return (d.day < 10 ? "0" : "") + d.day.toString() + "/" + (d.month < 10 ? "0" : "") + d.month.toString() + "/" + d.year.toString();
    } catch (e) {
      return null;
    }
  }
}