import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/material/material_didatico.dart';
import 'package:redesign/modulos/material/material_form.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/item_lista_simples.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialLista extends StatefulWidget {

  @override
  MaterialListaState createState() => MaterialListaState();
}

class MaterialListaState extends State<MaterialLista> {

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Materiais",
      body: _buildBody(context),
      fab: MyApp.isLabDis() ?
        FloatingActionButton(
          onPressed: () => novoMaterial(),
          child: Icon(Icons.add),
          backgroundColor: Style.main.primaryColor,
        )
          : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(MaterialDidatico.collectionName)
          .orderBy("data")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        if(snapshot.data.documents.length == 0)
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Ainda não temos materiais disponíveis"),
            ],
          );

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(
        children: [
          Expanded(
            child:  ListView(
              children: snapshot.map((data) => _buildListItem(context, data)).toList(),
            ),
          ),
        ]
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    MaterialDidatico material = MaterialDidatico.fromMap(data.data, reference: data.reference);

    return ItemListaSimples(
      material.titulo,
      (){ _launchURL(material.url); },
      subtitulo: material.descricao,
      iconeExtra: Icon(
        Icons.link,
        color: Style.main.primaryColor,
      ),
      key: ValueKey(data.documentID),
      onLongPress: MyApp.isLabDis() ? () => _apagarMaterial(material) : null,
    );
  }

  novoMaterial(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MaterialForm())
    );
  }

  _launchURL(String url) async{
    if (await canLaunch(url)) {
      await launch(url);
    }
  }


  Future<void> _apagarMaterial(MaterialDidatico material) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Apagar Material'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Deseja apagar o material "' + material.titulo + '"?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.deepOrange,
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              textColor: Colors.deepOrange,
              child: Text('Apagar'),
              onPressed: () {
                material.reference.delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}