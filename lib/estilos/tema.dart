import 'package:flutter/material.dart';

class Tema {

  static ThemeData principal = ThemeData(
    // Define the default Brightness and Colors
    brightness: Brightness.light,
    primaryColor: const Color.fromARGB(255, 55, 116, 127),
    accentColor: const Color.fromARGB(255, 27, 60, 65),
    primarySwatch: Colors.blue,
    primaryColorDark: const Color.fromARGB(255, 16, 36, 40),

    // Define the default Font Family
    fontFamily: 'Montserrat',

    // Define the default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
//    textTheme: TextTheme(
//      headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
//      title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
//      body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
//    ),
  );

  static const Color cinzaClaro = const Color.fromARGB(255, 240, 240, 240);

  static const Color buttonDarkGrey = const Color.fromARGB(255, 20, 45, 50);
  static const Color buttonYellow = const Color.fromARGB(255, 62, 53, 24);
  static const Color buttonPurple = const Color.fromARGB(255, 38, 28, 54);

}