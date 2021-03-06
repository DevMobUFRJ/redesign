import 'dart:ui';

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
import 'package:file_picker/file_picker.dart';

FocusNode _focusDescription = FocusNode();

class ForumPostForm extends StatefulWidget {
  final ForumTopic topic;
  final ForumPost editPost;

  ForumPostForm({this.topic, this.editPost});

  @override
  ForumPostFormState createState() => ForumPostFormState();
}

class ForumPostFormState extends State<ForumPostForm> {
  

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool blocked = false;
  ForumPost post = ForumPost();

  String filePath = 'nenhum';

  void _openFileExplorer(FileType type) async {
    filePath = await FilePicker.getFilePath(
        type: type, fileExtension: 'pdf');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: widget.editPost == null ? "Novo Problema" : "Editar post",
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
                          validator: (val) =>
                              val.isEmpty ? 'Título é obrigatório' : null,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50)
                          ],
                          onSaved: (val) => widget.editPost == null
                              ? post.title = val
                              : widget.editPost.title = val,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (v) => FocusScope.of(context)
                              .requestFocus(_focusDescription),
                          initialValue: widget.editPost == null ? '' : widget.editPost.title,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              icon: const Icon(Icons.description),
                              labelText: 'Descrição',
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            validator: (val) => val.isEmpty
                                ? 'Descrição é obrigatório'
                                : val.length > 15
                                    ? null
                                    : 'Descreva melhor seu problema',
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(500)
                            ],
                            onSaved: (val) => widget.editPost == null
                                ? post.description = val
                                : widget.editPost.description = val,
                            focusNode: _focusDescription,
                            textInputAction: TextInputAction.send,
                            onFieldSubmitted: (v) => _submitForm,
                            initialValue: widget.editPost == null ? '' : widget.editPost.description,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Icon(Icons.attach_file),
                            SizedBox(width: 16),
                            GestureDetector(
                              child: Container(
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  'Anexar imagem',
                                  style: TextStyle(color: Colors.white),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: Style.primaryColor,
                                ),
                              ),
                              onTap: () => _openFileExplorer(FileType.image),
                            ),
                            SizedBox(width: 16,),
                            GestureDetector(
                              child: Container(
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  'Anexar documento',
                                  style: TextStyle(color: Colors.white),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: Style.primaryColor,
                                ),
                              ),
                              onTap: () => _openFileExplorer(FileType.custom),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Text('Arquivo selecionado: ' + filePath.split('/').last),
                        )

                      ],
                    ),
                  )
                ],
              ),
            ),
            StandardButton(
                "Salvar",
                widget.editPost == null ? _submitForm : _submitEdit,
                Style.main.primaryColor,
                Style.lightGrey),
          ],
        ),
      ),
    );
  }

  void _submitEdit() {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Por favor, complete todos os campos.');
    } else {
      form.save();
      widget.editPost.date = DateTime.now();
      editPost();
    }
  }

  void _submitForm() {
    if (blocked) return;

    blocked = true;
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Por favor, complete todos os campos.');
    } else {
      form.save(); //Executa cada evento "onSaved" dos campos do formulário
      post.createdBy = MyApp.userId();
      post.topicId = widget.topic.reference.documentID;
      post.date = DateTime.now();
      post.savePost(filePath).then(saved);
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    blocked = false;
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
  }

  void editPost() {
    widget.editPost.updatePost();
    Navigator.pop(context);
  }

  void saved(DocumentReference doc) {
    Navigator.pop(context);
  }
}
