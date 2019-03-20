import 'package:flutter/material.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/rede/rede_list.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/simple_list_item.dart';
import 'package:redesign/widgets/base_screen.dart';

class RedeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Rede",
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              SimpleListItem(
                'Favoritos',
                () => listItem("Favoritos", context),
                iconExtra: Icon(
                  Icons.star,
                  color: Style.main.primaryColor,
                ),
              ),
              MyApp.isStudent()
                  ? null
                  : SimpleListItem('Laboratórios',
                      () => listItem(Occupation.laboratorio, context)),
              SimpleListItem(
                  'Escolas', () => listItem(Occupation.escola, context)),
              MyApp.isStudent()
                  ? null
                  : SimpleListItem('Incubadoras',
                      () => listItem(Occupation.incubadora, context)),
            ].where((w) => w != null).toList(),
          ),
        ),
      ),
    );
  }

  listItem(String occupation, context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RedeList(occupation)),
    );
  }
}
