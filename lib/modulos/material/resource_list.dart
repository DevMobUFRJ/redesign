import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/material/didactic_resource.dart';
import 'package:redesign/modulos/material/resource_form.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:redesign/widgets/simple_list_item.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceList extends StatefulWidget {
  @override
  ResourceListState createState() => ResourceListState();
}

class ResourceListState extends State<ResourceList> {
  /// Armazena o caminho/pasta atual que estamos visualizando
  String currentPath = DidacticResource.collectionName;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Materiais",
      body: _buildBody(context),
      fab: MyApp.isLabDis()
          ? FloatingActionButton(
              onPressed: () => newResource(),
              child: const Icon(Icons.add),
              backgroundColor: Style.main.primaryColor,
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(currentPath)
          .orderBy("eh_pasta", descending: true)
          .orderBy("data", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        if (snapshot.data.documents.length == 0 && !currentPath.contains("/"))
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[],
          );

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(children: [
      Expanded(
        child: ListView(
          children: [
            currentPath.contains("/")
                ? Column(
                    children: [
                      ListTile(
                        title: const Text("Voltar à pasta anterior"),
                        leading: const Icon(
                          Icons.arrow_back,
                          size: 20,
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.all(0),
                        onTap: exitFolder,
                      ),
                      const Divider(
                        color: Colors.black38,
                        height: 4,
                      )
                    ],
                  )
                : Container(),
            snapshot.length == 0
                ? Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text("Ainda não temos materiais aqui."),
                    alignment: Alignment.center,
                  )
                : Container(),
          ]..addAll(
              snapshot.map((data) => _buildListItem(context, data)).toList()),
        ),
      ),
    ]);
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    DidacticResource material =
        DidacticResource.fromMap(data.data, reference: data.reference);

    if (material.isFolder) {
      return SimpleListItem(
        material.title,
        () {
          enterFolder(material);
        },
        titleFontSize: 18,
        subtitle: material.description,
        iconExtra: const Icon(
          Icons.folder,
          color: Style.primaryColor,
        ),
        key: ValueKey(data.documentID),
        onLongPress: MyApp.isLabDis() ? () => _deleteResource(material) : null,
      );
    } else {
      return SimpleListItem(
        material.title,
        () {
          _launchURL(material.url);
        },
        titleFontSize: 18,
        subtitle: material.description,
        iconExtra: const Icon(
          Icons.link,
          color: Style.primaryColor,
        ),
        key: ValueKey(data.documentID),
        onLongPress: MyApp.isLabDis() ? () => _deleteResource(material) : null,
      );
    }
  }

  enterFolder(DidacticResource material) {
    if (material.isFolder)
      setState(() {
        currentPath +=
            "/${material.reference.documentID}/${DidacticResource.collectionName}";
      });
  }

  exitFolder() {
    if (currentPath.contains("/")) {
      String newPath = currentPath;
      int lastSlash = newPath.lastIndexOf("/");
      newPath = newPath.replaceRange(lastSlash, newPath.length, "");
      lastSlash = newPath.lastIndexOf("/");
      newPath = newPath.replaceRange(lastSlash, newPath.length, "");

      setState(() {
        currentPath = newPath;
      });
    }
  }

  newResource() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ResourceForm(currentPath)));
  }

  _launchURL(String url) async {
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
          title: const Text('Apagar Material'),
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
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              textColor: Colors.deepOrange,
              child: const Text('Apagar'),
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
