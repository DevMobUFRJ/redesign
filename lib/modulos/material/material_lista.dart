import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/material/material_didatico.dart';
import 'package:redesign/modulos/material/material_form.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/item_lista_simples.dart';
import 'package:redesign/widgets/tela_base.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialLista extends StatefulWidget {

  @override
  MaterialListaState createState() => MaterialListaState();
}

class MaterialListaState extends State<MaterialLista> {

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: "Materiais",
      body: _buildBody(context),
      fab: MeuApp.ehLabDis() ?
        FloatingActionButton(
          onPressed: () => novoMaterial(),
          child: Icon(Icons.add),
          backgroundColor: Tema.principal.primaryColor,
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
    MaterialDidatico material = MaterialDidatico.fromMap(data.data);

    return ItemListaSimples(
      material.titulo,
      (){ _launchURL(material.url); },
      subtitulo: material.descricao,
      iconeExtra: Icon(
        Icons.link,
        color: Tema.principal.primaryColor,
      ),
      key: ValueKey(data.documentID),
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
}