import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/widgets/tela_base.dart';

class AutorizacaoTela extends StatefulWidget {
  @override
  _AutorizacaoTelaState createState() => _AutorizacaoTelaState();
}

class _AutorizacaoTelaState extends State<AutorizacaoTela> {
  bool buscando = false;
  TextEditingController _buscaController = TextEditingController();
  String busca = "";

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: "Autorizar Usuários",
      body: _buildBody(context),
      actions: <IconButton>[
        IconButton(
          icon: Icon(
              Icons.search,
              color: Colors.white
          ),
          onPressed: () => alternarBusca(),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(Usuario.collectionName)
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
          buscando ?
          Container(
              margin: EdgeInsets.only(bottom: 5),
              decoration: ShapeDecoration(shape: StadiumBorder() ),
              child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: textoBuscaMudou,
                        controller: _buscaController,
                        cursorColor: Tema.cinzaClaro,
                        decoration: InputDecoration(
                            hintText: "Buscar",
                            prefixIcon: Icon(Icons.search, color: Tema.primaryColor)
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
    Usuario usuario = Usuario.fromMap(data.data, reference: data.reference);

    if(!usuario.nome.toLowerCase().contains(busca)
        && !usuario.email.toLowerCase().contains(busca))
      return Container();

    return ListTile(
      isThreeLine: true,
      title: Text(usuario.nome),
      subtitle: Text((usuario.tipo == TipoUsuario.pessoa ? "Pessoa" : "Instituição" ) + ' | ' + usuario.email),
      onTap: () => _autorizacaoDialog(usuario),
    );
  }

  alternarBusca(){
    setState((){
      buscando = !buscando;
    });
    if(!buscando) {
      _buscaController.text = "";
      textoBuscaMudou("");
    }
  }

  textoBuscaMudou(String texto){
    setState(() {
      busca = texto.toLowerCase();
    });
  }

  Future<void> _autorizacaoDialog(Usuario usuario) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(usuario.nome),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Email: " + usuario.email),
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
                usuario.reference.updateData({'ativo': -1}).then((d) => Navigator.pop(context));
              },
            ),
            FlatButton(
              child: Text('Autorizar'),
              onPressed: () {
                usuario.reference.updateData({'ativo': 1}).then((d) => Navigator.pop(context));
              },
            ),
          ],
        );
      },
    );
  }
}