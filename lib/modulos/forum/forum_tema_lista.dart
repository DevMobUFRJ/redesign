import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/modulos/forum/forum_post_lista.dart';
import 'package:redesign/modulos/forum/forum_tema.dart';
import 'package:redesign/widgets/item_lista_simples.dart';
import 'package:redesign/widgets/base_screen.dart';

class ForumTemaLista extends StatefulWidget {

  @override
  ForumTemaListaState createState() => ForumTemaListaState();
}

class ForumTemaListaState extends State<ForumTemaLista> {
  bool buscando = false;
  TextEditingController _buscaController = TextEditingController();
  String busca = "";

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Fórum",
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
      stream: Firestore.instance.collection(ForumTema.collectionName)
          .orderBy("titulo")
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
              children: [
                buscando ?
                Container(
                  margin: EdgeInsets.only(bottom: 5),
                  decoration: ShapeDecoration(shape: StadiumBorder()),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: textoBuscaMudou,
                          controller: _buscaController,
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
              ]
              ..addAll(snapshot.map((data) => _buildListItem(context, data)).toList()),
            ),
          ),
        ]
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    ForumTema tema = ForumTema.fromMap(data.data, reference: data.reference);

    if(!tema.titulo.toLowerCase().contains(busca))
      return Container();

    return ItemListaSimples(
      tema.titulo,
      () => tapItem(tema),
      key: ValueKey(data.documentID)
    );
  }

  tapItem(ForumTema tema){
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => ForumPostLista(tema),),
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
}