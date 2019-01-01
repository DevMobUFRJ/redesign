import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_instituicao.dart';
import 'package:redesign/modulos/usuario/perfil_pessoa.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/widgets/item_lista_simples.dart';
import 'package:redesign/widgets/tela_base.dart';

class RedeLista extends StatefulWidget {
  final String ocupacao;

  RedeLista(this.ocupacao, {Key key}) : super(key: key);

  @override
  RedeListaState createState() => RedeListaState(ocupacao);
}

class RedeListaState extends State<RedeLista> {
  bool buscando = false;
  TextEditingController _buscaController = TextEditingController();
  String busca = "";

  final String ocupacao;

  RedeListaState(this.ocupacao);

  @override
  Widget build(BuildContext context) {
    return TelaBase(
        title: ocupacao,
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
          .where("ocupacao", isEqualTo: this.ocupacao)
          .orderBy("nome")
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
              ]
              ..addAll(snapshot.map((data) => _buildListItem(context, data)).toList()),
            ),
          ),
        ]
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    Usuario usuario;
    Instituicao instituicao;

    if(data.data['tipo'] == TipoUsuario.pessoa.index) {
      usuario = Usuario.fromMap(data.data, reference: data.reference);
      if(!usuario.nome.toLowerCase().contains(busca)
          && !usuario.descricao.toLowerCase().contains(busca))
        return Container();
    } else {
      instituicao = Instituicao.fromMap(data.data, reference: data.reference);
      if(!instituicao.nome.toLowerCase().contains(busca)
          && !instituicao.descricao.toLowerCase().contains(busca))
        return Container();
    }

    return ItemListaSimples(
      usuario != null ? usuario.nome : instituicao.nome,
      usuario != null ? () => callbackUsuario(usuario) :
                        () => callbackInstituicao(instituicao),
      corTexto: Tema.textoEscuro,
      key: ValueKey(data.documentID),
    );

  }

  void callbackUsuario(Usuario usuario){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerfilPessoa(usuario),
      ),
    );
  }

  void callbackInstituicao(Instituicao instituicao){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerfilInstituicao(instituicao),
      ),
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