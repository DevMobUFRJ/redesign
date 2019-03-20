import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/material/didactic_resource.dart';
import 'package:redesign/modulos/material/resource_form.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/simple_list_item.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceList extends StatefulWidget {

  @override
  ResourceListState createState() => ResourceListState();
}

class ResourceListState extends State<ResourceList> {

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Materiais",
      body: _buildBody(context),
      fab: MyApp.isLabDis() ?
        FloatingActionButton(
          onPressed: () => newResource(),
          child: Icon(Icons.add),
          backgroundColor: Style.main.primaryColor,
        )
          : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(DidacticResource.collectionName)
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
    DidacticResource material = DidacticResource.fromMap(data.data, reference: data.reference);

    return SimpleListItem(
      material.title,
      (){ _launchURL(material.url); },
      subtitle: material.description,
      iconExtra: Icon(
        Icons.link,
        color: Style.main.primaryColor,
      ),
      key: ValueKey(data.documentID),
      onLongPress: MyApp.isLabDis() ? () => _deleteResource(material) : null,
    );
  }

  newResource(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResourceForm())
    );
  }

  _launchURL(String url) async{
    if (await canLaunch(url)) {
      await launch(url);
    }
  }


  Future<void> _deleteResource(DidacticResource resource) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Apagar Material'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Deseja apagar o material "' + resource.title + '"?'),
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
                resource.reference.delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}