import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/forum/forum_post.dart';
import 'package:redesign/modulos/forum/forum_topic.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/widgets/standard_button.dart';
import 'package:redesign/widgets/base_screen.dart';

class ForumPostForm extends StatefulWidget {
  final ForumTopic topic;

  ForumPostForm(this.topic);

  @override
  ForumPostFormState createState() => ForumPostFormState(topic);
}

class ForumPostFormState extends State<ForumPostForm> {
  ForumTopic topic;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool blocked = false;

  ForumPost post = ForumPost();

  ForumPostFormState(this.topic);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Novo Problema",
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
                          onSaved: (val) => post.title = val,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 70.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              icon: const Icon(Icons.description),
                              labelText: 'Descrição',
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            validator: (val) => val.isEmpty ? 'Descrição é obrigatório' :
                            val.length > 15 ? null : 'Descreva melhor seu problema',
                            inputFormatters: [LengthLimitingTextInputFormatter(500)],
                            onSaved: (val) => post.description = val,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: StandardButton("Salvar", _submitForm,
                Style.main.primaryColor, Style.lightGrey
              )
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
      post.createdBy = MyApp.userId();
      post.topicId = topic.reference.documentID;
      post.date = DateTime.now();
      savePost(post);
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    blocked = false;
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
  }

  savePost(ForumPost post){
    Firestore.instance.collection(ForumPost.collectionName).add(post.toJson()).then(saved); //TODO pegar o erro
  }

  saved(DocumentReference doc){
    Navigator.pop(context);
  }
}