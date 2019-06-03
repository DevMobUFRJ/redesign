import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/forum/forum_comment.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/standard_button.dart';
import 'package:redesign/widgets/base_screen.dart';

FocusNode _focusDescription = FocusNode();

class ForumCommentForm extends StatefulWidget {
  final CollectionReference reference;

  ForumCommentForm(this.reference);

  @override
  ForumCommentFormState createState() => ForumCommentFormState(reference);
}

class ForumCommentFormState extends State<ForumCommentForm> {
  CollectionReference reference;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool blocked = false;

  ForumComment comment = ForumComment();

  ForumCommentFormState(this.reference);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Nova Solução",
      body: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Form(
              key: _formKey,
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
                          onSaved: (val) => comment.title = val,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (v){
                            FocusScope.of(context).requestFocus(_focusDescription);
                          },
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
                            onSaved: (val) => comment.description = val,
                            focusNode: _focusDescription,
                            textInputAction: TextInputAction.send,
                            onFieldSubmitted: (v) => _submitForm(),
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
      comment.createdBy = MyApp.userId();
      comment.date = DateTime.now();
      save(comment);
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    blocked = false;
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
  }

  save(ForumComment comment){
    reference.add(comment.toJson()).then(savedSuccessfully); //TODO pegar o erro
  }

  savedSuccessfully(DocumentReference doc){
    Navigator.pop(context);
  }
}