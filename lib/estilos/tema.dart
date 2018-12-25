import 'package:flutter/material.dart';

class Tema {

  static ThemeData principal = ThemeData(
    // Define the default Brightness and Colors
    brightness: Brightness.light,
    primaryColor: const Color.fromARGB(255, 55, 116, 127),
    accentColor: Colors.cyan[600],
    primarySwatch: Colors.blue,

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
}