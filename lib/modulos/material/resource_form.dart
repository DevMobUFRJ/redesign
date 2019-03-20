import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/material/didactic_resource.dart';
import 'package:redesign/services/validators.dart';
import 'package:redesign/widgets/standard_button.dart';
import 'package:redesign/widgets/base_screen.dart';

class ResourceForm extends StatefulWidget {
  @override
  ResourceFormState createState() => ResourceFormState();
}

class ResourceFormState extends State<ResourceForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool blocked = false;

  DidacticResource resource = DidacticResource();

  ResourceFormState();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Novo Material",
      body: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Form(
          key: _formKey,
          autovalidate: true,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.short_text),
                  labelText: 'Título',
                ),
                validator: (val) => val.trim().isEmpty ? 'Título é obrigatório' : null,
                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                onSaved: (val) => resource.title = val.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.description),
                  labelText: 'Descrição',
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(200)],
                onSaved: (val) => resource.description = val.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.link),
                  labelText: 'Link',
                ),
                validator: (val) => val.isEmpty ? 'Link é obrigatório' :
                  Validators.url(val) ? null : 'Link inválido',
                inputFormatters: [LengthLimitingTextInputFormatter(70)],
                onSaved: (val){
                  if(!val.startsWith("http")){
                    val = "http://" + val;
                  }
                  resource.url = val;
                },
              ),
              Container(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: StandardButton("Enviar", _submitForm,
                      Style.main.primaryColor, Style.lightGrey)
              ),
            ],
          ),
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
      resource.date = DateTime.now();
      save(resource);
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    blocked = false;
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
  }

  save(DidacticResource resource){
    Firestore.instance.collection(DidacticResource.collectionName).add(resource.toJson()).then(savedSuccessfully); //TODO pegar o erro
  }

  savedSuccessfully(DocumentReference doc){
    Navigator.pop(context);
  }
}