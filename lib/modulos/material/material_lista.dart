import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/material/material_didatico.dart';
import 'package:redesign/modulos/material/material_form.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/widgets/tela_base.dart';

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

    return Container(
      key: ValueKey(data.documentID),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
            title: Text(material.titulo),
            subtitle: Text(material.url),
            trailing: Icon(
              Icons.link,
              color: Tema.principal.primaryColor,
            ),
            onTap: (){ /* TODO Abrir a url */ },
          )
      ),
    );
  }

  novoMaterial(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MaterialForm())
    );
  }
}