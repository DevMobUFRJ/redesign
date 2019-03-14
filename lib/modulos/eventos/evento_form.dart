import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redesign/estilos/fb_icon_icons.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/modulos/eventos/evento.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/services/validators.dart';
import 'package:redesign/widgets/standard_button.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventoCriar extends StatelessWidget {

  final Evento evento;

  EventoCriar({this.evento});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: evento == null || evento.reference == null ? "Novo Evento" : "Editar Evento",
        body: EventoCriarPage(evento: this.evento)
    );
  }
}

class EventoCriarPage extends StatefulWidget{

  final Evento evento;

  EventoCriarPage({this.evento});

  @override
  _EventoCriarState createState() => _EventoCriarState(this.evento);
}

class _EventoCriarState extends State<EventoCriarPage>{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _horaController = TextEditingController();

  Evento evento;
  bool blocked = false;

  _EventoCriarState(this.evento){
    if(evento == null){
      evento = Evento();
    }
    // Precisa ser inicializado fora pois o TextField não aceita um
    // controller e um initialValue simultãneamente.
    if(evento.data != null){
      String hora = convertToHMString(evento.data);
      if(hora != null)
        _horaController.text = hora;
    }
  }

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
                initialValue: evento.nome,
                validator: (val) => val.isEmpty ? 'Nome é obrigatório' : null,
                inputFormatters: [new LengthLimitingTextInputFormatter(50)],
                onSaved: (val) => evento.nome = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.calendar_today),
                  labelText: 'Data (dd/mm/aaaa)',
                ),
                initialValue: convertToDMYString(evento.data),
                keyboardType: TextInputType.datetime,
                inputFormatters: [new LengthLimitingTextInputFormatter(10)],
                validator: (val) =>
                  ehDataValida(val) ? null : 'Data inválida',
                onSaved: (val) => evento.data = convertToDateTime(val),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.calendar_today),
                  labelText: 'Hora (ex. 16:30)',
                ),
                controller: _horaController,
                //initialValue: ,
                keyboardType: TextInputType.datetime,
                inputFormatters: [new LengthLimitingTextInputFormatter(5)],
                validator: (val) =>
                  ehHoraValida(val) ? null : 'Hora inválida',
                //Não precisa de onSaved pois é salvo c/ a data pelo controller
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.home),
                  labelText: 'Nome do Local',
                ),
                initialValue: evento.local,
                validator: (val) => val.isEmpty ? 'Local é obrigatório' : null,
                inputFormatters: [new LengthLimitingTextInputFormatter(50)],
                onSaved: (val) => evento.local = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.location_on),
                  labelText: 'Endereço',
                ),
                initialValue: evento.endereco,
                validator: (val) => val.isEmpty ? 'Endereço é obrigatório' : null,
                inputFormatters: [new LengthLimitingTextInputFormatter(100)],
                onSaved: (val) => evento.endereco = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.location_city),
                  labelText: 'Cidade',
                ),
                initialValue: evento.cidade,
                validator: (val) => val.isEmpty ? 'Cidade é obrigatório' : null,
                inputFormatters: [new LengthLimitingTextInputFormatter(20)],
                onSaved: (val) => evento.cidade = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.description),
                  labelText: 'Descrição',
                ),
                initialValue: evento.descricao,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                validator: (val) => val.isEmpty ? 'Descrição é obrigatório' :
                val.length > 20 ? null : 'Descreva melhor seu evento',
                inputFormatters: [new LengthLimitingTextInputFormatter(500)],
                onSaved: (val) => evento.descricao = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(FbIcon.facebook_official),
                  labelText: 'Link do Evento no facebook',
                ),
                initialValue: evento.facebookUrl,
                validator: (val) => Validators.facebookUrl(val) ? null : 'Link inválido',
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [new LengthLimitingTextInputFormatter(80)],
                onSaved: (val) => evento.facebookUrl = val,
              ),
              Container(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: StandardButton("Salvar", _submitForm,
                      Style.main.primaryColor, Style.lightGrey)
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

  bool ehHoraValida(String hora) {
    if (hora.isEmpty)
      return false;
    var d = convertToHour(hora);
    return d != null;
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

  DateTime convertToHour(String input) {
    try
    {
      var d = DateFormat("Hm").parse(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  DateTime convertToDateTime(String inputData){
    return DateFormat("d/M/y H:m").parse(inputData + " " + _horaController.text);
  }

  String convertToDMYString(DateTime d){
    try{
      return d.day.toString() + "/" + d.month.toString() + "/" + d.year.toString();
    } catch (e) {
      return null;
    }
  }

  String convertToHMString(DateTime d){
    try{
      return d.hour.toString() + ":" + d.minute.toString();
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
      form.save(); //Executa cada evento "onSaved" dos campos do formulário
      evento.criadoPor = MyApp.userId();

      if(evento.reference == null) {
        Firestore.instance
            .collection(Evento.collectionName)
            .add(evento.toJson())
            .then(onValue)
            .catchError(showMessage);
      } else {
        evento.reference.setData(evento.toJson()).then(onUpdate).catchError(showMessage);
      }
    }
  }

  void onValue(DocumentReference ref){
    Navigator.pop(context);
  }

  void onUpdate(dynamic yo){
    Navigator.pop(context);
  }
}