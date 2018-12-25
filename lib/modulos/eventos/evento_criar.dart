import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/eventos/evento.dart';
import 'package:redesign/widgets/botao_padrao.dart';
import 'package:redesign/widgets/tela_base.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventoCriar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TelaBase(
        title: "Novo Evento",
        body: EventoCriarPage()
    );
  }
}

class EventoCriarPage extends StatefulWidget{
  @override
  _EventoCriarState createState() => _EventoCriarState();
}

class _EventoCriarState extends State<EventoCriarPage>{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Evento evento = new Evento();
  bool blocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: Form(
          key: _formKey,
          autovalidate: true,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person),
                  labelText: 'Nome do Evento',
                ),
                validator: (val) => val.isEmpty ? 'Nome é obrigatório' : null,
                inputFormatters: [new LengthLimitingTextInputFormatter(50)],
                onSaved: (val) => evento.nome = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.calendar_today),
                  labelText: 'Data (dd/mm/aaaa)',
                ),
                keyboardType: TextInputType.datetime,
                inputFormatters: [new LengthLimitingTextInputFormatter(10)],
                validator: (val) =>
                ehDataValida(val) ? null : 'Data inválida',
                onSaved: (val) => evento.data = convertToDate(val),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.home),
                  labelText: 'Nome do Local',
                ),
                validator: (val) => val.isEmpty ? 'Local é obrigatório' : null,
                inputFormatters: [new LengthLimitingTextInputFormatter(50)],
                onSaved: (val) => evento.local = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.location_on),
                  labelText: 'Endereço',
                ),
                validator: (val) => val.isEmpty ? 'Endereço é obrigatório' : null,
                inputFormatters: [new LengthLimitingTextInputFormatter(100)],
                onSaved: (val) => evento.endereco = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.location_city),
                  labelText: 'Cidade',
                ),
                validator: (val) => val.isEmpty ? 'Cidade é obrigatório' : null,
                inputFormatters: [new LengthLimitingTextInputFormatter(20)],
                onSaved: (val) => evento.cidade = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.description),
                  labelText: 'Descrição',
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                validator: (val) => val.isEmpty ? 'Descrição é obrigatório' :
                val.length > 20 ? null : 'Descreva melhor seu evento',
                inputFormatters: [new LengthLimitingTextInputFormatter(500)],
                onSaved: (val) => evento.descricao = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.email),
                  labelText: 'Link do Evento no facebook',
                ),
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [new LengthLimitingTextInputFormatter(80)],
                onSaved: (val) => evento.facebookUrl = val,
              ),
              Container(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: BotaoPadrao("Salvar", _submitForm,
                      Tema.principal.primaryColor, Tema.cinzaClaro)
              )
            ],
          )
      ),
    );
  }

  bool ehDataValida(String data) {
    if (data.isEmpty)
      return false;
    var d = convertToDate(data);
    return d != null && d.isAfter(new DateTime.now());
  }

  DateTime convertToDate(String input) {
    try
    {
      var d = DateFormat("d/M/y").parse(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    blocked = false;
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  void _submitForm() {
    if(blocked) return;

    blocked = true;
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Por favor, complete todos os campos.');
    } else {
      form.save(); //This invokes each onSaved event
      Firestore.instance.collection(Evento.collectionName)
          .add(evento.toJson())
      .then(onValue)
      .catchError(showMessage);
    }
  }

  void onValue(DocumentReference ref){
    Navigator.pop(context);
  }
}