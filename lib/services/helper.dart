import 'package:redesign/modulos/user/user.dart';

class Helper {
  static const String emailLabdis = "labdis.ufrj@gmail.com";

  static const int maxProfileImageSize = 38000; // In bytes for storage.getData

  /// Retorna o nome da ocupação para o tipo de instituição passada.
  /// Ocupacao secundária: Aluno, Bolsista, Estudante.
  ///
  /// Ex: Para laboratórios, retorna "Bolsista".
  /// Para Escolas, retorna "Aluno"
  static String getSecondaryOccupationToInstitution(
      String institutionOccupation) {
    switch (institutionOccupation) {
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
  static String getSecondaryOccupationTitle(String institutionOccupation) {
    switch (institutionOccupation) {
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
  static String getOcupacaoPrimariaParaInstituicao(String ocupacaoInstituicao) {
    switch (ocupacaoInstituicao) {
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
  static String getPrimaryOccupationTitle(String institutionOccupation) {
    switch (institutionOccupation) {
      case Occupation.incubadora:
        return "Empreendedores";

      case Occupation.laboratorio:
      case Occupation.escola:
        return "Professores";

      default:
        return "Professores";
    }
  }

  /// Retorna um titulo no plural para a instituicao.
  static UserType getTypeFromOccupation(String occupation) {
    switch (occupation) {
      case Occupation.laboratorio:
      case Occupation.escola:
      case Occupation.empreendedor:
      case Occupation.incubadora:
        return UserType.institution;

      case Occupation.bolsista:
      case Occupation.discente:
      case Occupation.professor:
      case Occupation.aluno:
      case Occupation.outra:
      default:
        return UserType.person;
    }
  }

  static String convertToDMYString(DateTime d) {
    try {
      return (d.day < 10 ? "0" : "") +
          d.day.toString() +
          "/" +
          (d.month < 10 ? "0" : "") +
          d.month.toString() +
          "/" +
          d.year.toString();
    } catch (e) {
      return null;
    }
  }

  /// Retorna a sigla do mes em portugues
  static String initialsMonth(int numMonth) {
    if (numMonth < 1 || numMonth > 12) return "";

    const List<String> initialsOfMonths = [
      "JAN",
      "FEV",
      "MAR",
      "ABR",
      "MAI",
      "JUN",
      "JUL",
      "AGO",
      "SET",
      "OUT",
      "NOV",
      "DEZ"
    ];
    return initialsOfMonths[numMonth - 1];
  }

  /// Retorna o dia da semana em portugues
  static String dayOfWeekPortuguese(int day) {
    if (day < 1 || day > 7) return "";

    const List<String> dayOfWeek = [
      "Segunda-feira",
      "Terça-feira",
      "Quarta-feira",
      "Quinta-feira",
      "Sexta-feira",
      "Sábado",
      "Domingo"
    ];
    return dayOfWeek[day - 1];
  }

  /// Retorna a nome do mês em portugues
  static String monthPortuguese(int numMonth) {
    if (numMonth < 1 || numMonth > 12) return "";

    const List<String> monthsPortuguese = [
      "Janeiro",
      "Fevereiro",
      "Março",
      "Abril",
      "Maio",
      "Junho",
      "Julho",
      "Agosto",
      "Setembro",
      "Outubro",
      "Novembro",
      "Dezembro"
    ];
    return monthsPortuguese[numMonth - 1];
  }
}
