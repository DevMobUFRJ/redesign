import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/widgets/base_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool searching = false;
  TextEditingController _searchController = TextEditingController();
  String search = "";

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Autorizar Usuários",
      body: _buildBody(context),
      actions: <IconButton>[
        IconButton(
          icon: Icon(
              Icons.search,
              color: Colors.white
          ),
          onPressed: () => toggleSearch(),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(User.collectionName)
          .where("ativo", isEqualTo: 0)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        if(snapshot.data.documents.length == 0)
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Não há usuários a serem autorizados."),
            ],
          );

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Column(
        children: [
          searching ?
          Container(
              margin: EdgeInsets.only(bottom: 5),
              decoration: ShapeDecoration(shape: StadiumBorder() ),
              child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: searchTextChanged,
                        controller: _searchController,
                        cursorColor: Style.lightGrey,
                        decoration: InputDecoration(
                            hintText: "Buscar",
                            prefixIcon: Icon(Icons.search, color: Style.primaryColor)
                        ),
                      ),
                    ),
                  ]
              )
          )
              : Container(),
          Expanded(
            child:  ListView(
              children: snapshot.map((data) => _buildListItem(context, data)).toList(),
            ),
          ),
        ]
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    User user = User.fromMap(data.data, reference: data.reference);

    if(!user.name.toLowerCase().contains(search)
        && !user.email.toLowerCase().contains(search))
      return Container();

    return ListTile(
      isThreeLine: true,
      title: Text(user.name),
      subtitle: Text((user.type == UserType.person ? "Pessoa" : "Instituição" ) + ' | ' + user.email),
      onTap: () => _authDialog(user),
    );
  }

  toggleSearch(){
    setState((){
      searching = !searching;
    });
    if(!searching) {
      _searchController.text = "";
      searchTextChanged("");
    }
  }

  searchTextChanged(String text){
    setState(() {
      search = text.toLowerCase();
    });
  }

  Future<void> _authDialog(User user) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(user.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Email: " + user.email),
                Text('Escolha uma opção.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Bloquear'),
              onPressed: () {
                user.reference.updateData({'ativo': -1}).then((d) => Navigator.pop(context));
              },
            ),
            FlatButton(
              child: Text('Autorizar'),
              onPressed: () {
                user.reference.updateData({'ativo': 1}).then((d) => Navigator.pop(context));
              },
            ),
          ],
        );
      },
    );
  }
}