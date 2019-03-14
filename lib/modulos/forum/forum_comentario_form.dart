import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/modulos/forum/forum_comentario.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/standard_button.dart';
import 'package:redesign/widgets/base_screen.dart';

class ForumComentarioForm extends StatefulWidget {
  final CollectionReference reference;

  ForumComentarioForm(this.reference);

  @override
  ForumComentarioFormState createState() => ForumComentarioFormState(reference);
}

class ForumComentarioFormState extends State<ForumComentarioForm> {
  CollectionReference reference;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool blocked = false;

  ForumComentario comentario = ForumComentario();

  ForumComentarioFormState(this.reference);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Nova Solução",
      body: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Form(
              key: _formKey,
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: const Icon(Icons.short_text),
                            labelText: 'Título',
                          ),
                          validator: (val) => val.isEmpty ? 'Título é obrigatório' : null,
                          inputFormatters: [LengthLimitingTextInputFormatter(50)],
                          onSaved: (val) => comentario.titulo = val,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 70.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              icon: const Icon(Icons.description),
                              labelText: 'Solução',
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            validator: (val) => val.isEmpty ? 'Descrição é obrigatório' :
                              val.length > 15 ? null : 'Descreva melhor sua solução',
                            inputFormatters: [LengthLimitingTextInputFormatter(500)],
                            onSaved: (val) => comentario.descricao = val,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20.0),
              child: StandardButton("Enviar", _submitForm,
                  Style.main.primaryColor, Style.lightGrey)
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if(blocked) return;

    blocked = true;
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Por favor, complete todos os campos.');
    } else {
      form.save(); //Executa cada evento "onSaved" dos campos do formulário
      comentario.criadoPor = MyApp.userId();
      comentario.data = DateTime.now();
      salvar(comentario);
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    blocked = false;
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
  }

  salvar(ForumComentario comentario){
    reference.add(comentario.toJson()).then(salvou); //TODO pegar o erro
  }

  salvou(DocumentReference doc){
    Navigator.pop(context);
  }
}