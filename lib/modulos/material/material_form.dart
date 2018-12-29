import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/material/material_didatico.dart';
import 'package:redesign/servicos/validadores.dart';
import 'package:redesign/widgets/botao_padrao.dart';
import 'package:redesign/widgets/tela_base.dart';

class MaterialForm extends StatefulWidget {
  @override
  MaterialFormState createState() => MaterialFormState();
}

class MaterialFormState extends State<MaterialForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool blocked = false;

  MaterialDidatico material = MaterialDidatico();

  MaterialFormState();

  @override
  Widget build(BuildContext context) {
    return TelaBase(
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
                validator: (val) => val.isEmpty ? 'Título é obrigatório' : null,
                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                onSaved: (val) => material.titulo = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.link),
                  labelText: 'Link',
                ),
                validator: (val) => val.isEmpty ? 'Link é obrigatório' :
                  Validadores.url(val) ? null : 'Link inválido',
                inputFormatters: [LengthLimitingTextInputFormatter(70)],
                onSaved: (val) => material.url = val,
              ),
              Container(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: BotaoPadrao("Enviar", _submitForm,
                      Tema.principal.primaryColor, Tema.cinzaClaro)
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
      material.data = DateTime.now();
      salvar(material);
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    blocked = false;
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
  }

  salvar(MaterialDidatico material){
    Firestore.instance.collection(MaterialDidatico.collectionName).add(material.toJson()).then(salvou); //TODO pegar o erro
  }

  salvou(DocumentReference doc){
    Navigator.pop(context);
  }
}