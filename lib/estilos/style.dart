import 'package:flutter/material.dart';

/// Tema padrão do app, aplicado no MaterialApp no arquivo main.dart e
/// ao longo do app quando são necessárias cores para botões, textos etc.
class Style {

  // ===== TEMA PADRÃO ===== //
  static ThemeData main = ThemeData(
    brightness: Brightness.light,
    primaryColor: Style.primaryColor,
    accentColor: const Color.fromARGB(255, 27, 60, 65),
    primarySwatch: Colors.blue,
    primaryColorDark: const Color.fromARGB(255, 42, 92, 102),
    dividerColor: const Color.fromARGB(0, 0, 0, 0),
  );

  // ===== CORES EXTRAS ===== //
  static const Color lightGrey = Color.fromARGB(255, 240, 240, 240);
  static const Color darkText = Colors.black45;
  static const Color buttonBlue = Color.fromARGB(255, 52, 116, 128);
  static const Color buttonGrey = Color.fromARGB(255, 48, 67, 76);
  static const Color purple = Color.fromARGB(255, 96, 72, 137);
  static const Color yellow = Color.fromARGB(255, 159, 135, 60);
  static const Color buttonDarkGrey = Color.fromARGB(255, 20, 45, 50);
  static const Color primaryColor = Color.fromARGB(255, 52, 116, 128);
  static const Color primaryColorTransparency = Color.fromARGB(170, 52, 116, 128);
  static const Color primaryColorLighter = Color.fromARGB(255, 69, 153, 169);
  static const Color darkBackground = Color.fromARGB(255, 15, 34, 38);
}