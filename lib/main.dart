import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/modulos/login/login.dart';
import 'package:redesign/modulos/map/map_screen.dart';
import 'package:firebase_analytics/observer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: Style.main,
      initialRoute: '/',

      routes: <String, WidgetBuilder>{
        '/': (context) => MapScreen(),
        '/login': (context) => Login(),
      },
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}
