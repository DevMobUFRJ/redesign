import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:redesign/modulos/events/event.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/services/validators.dart';
import 'package:redesign/styles/fb_icon_icons.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:redesign/widgets/standard_button.dart';

class CreateEvent extends StatelessWidget {
  final Event event;

  CreateEvent({this.event});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: event == null || event.reference == null
            ? "Novo Evento"
            : "Editar Evento",
        body: CreateEventPage(event: this.event));
  }
}

class CreateEventPage extends StatefulWidget {
  final Event event;

  CreateEventPage({this.event});

  @override
  _CreateEventState createState() => _CreateEventState(this.event);
}

class _CreateEventState extends State<CreateEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _hourController = TextEditingController();
  // Os controllers repetidos abaixo são necessários para evitar que o valor
  // do campo seja perdido quando o usuario rolar a tela
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _addrController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _fbController = TextEditingController();

  Event event;
  bool blocked = false;

  _CreateEventState(this.event) {
    if (event == null) {
      event = Event();
    }
    // Precisa ser inicializado fora pois o TextField não aceita um
    // controller e um initialValue simultãneamente.
    if (event.date != null) {
      String hour = convertToHMString(event.date);
      if (hour != null) _hourController.text = hour;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person),
                  labelText: 'Nome do Evento',
                ),
                initialValue: event.name,
                validator: (val) => val.isEmpty ? 'Nome é obrigatório' : null,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                onSaved: (val) => event.name = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.calendar_today),
                  labelText: 'Data (dd/mm/aaaa)',
                ),
                initialValue: convertToDMYString(event.date),
                keyboardType: TextInputType.datetime,
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
                validator: (val) => isDateValid(val) ? null : 'Data inválida',
                onSaved: (val) => event.date = convertToDateTime(val),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.calendar_today),
                  labelText: 'Hora (ex. 16:30)',
                ),
                controller: _hourController,
                keyboardType: TextInputType.datetime,
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
                validator: (val) => isHourValid(val) ? null : 'Hora inválida',
                //Não precisa de onSaved pois é salvo c/ a data pelo controller
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.home),
                  labelText: 'Nome do Local',
                ),
                initialValue: event.local,
                validator: (val) => val.isEmpty ? 'Local é obrigatório' : null,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                onSaved: (val) => event.local = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.location_on),
                  labelText: 'Endereço',
                ),
                initialValue: event.address,
                validator: (val) =>
                    val.isEmpty ? 'Endereço é obrigatório' : null,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                onSaved: (val) => event.address = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.location_city),
                  labelText: 'Cidade',
                ),
                initialValue: event.city,
                validator: (val) => val.isEmpty ? 'Cidade é obrigatório' : null,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                onSaved: (val) => event.city = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.description),
                  labelText: 'Descrição',
                ),
                initialValue: event.description,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                validator: (val) => val.isEmpty
                    ? 'Descrição é obrigatório'
                    : val.length > 20 ? null : 'Descreva melhor seu evento',
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
                onSaved: (val) => event.description = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(FbIcon.facebook_official),
                  labelText: 'Link do Evento no facebook',
                ),
                initialValue: event.facebookUrl,
                validator: (val) =>
                    Validators.facebookUrl(val) ? null : 'Link inválido',
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [LengthLimitingTextInputFormatter(80)],
                onSaved: (val) => event.facebookUrl = val,
              ),
              Container(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: StandardButton("Salvar", _submitForm,
                      Style.main.primaryColor, Style.lightGrey))
            ],
          )),
    );
  }

  bool isDateValid(String date) {
    if (date.isEmpty) return false;
    var d = convertToDate(date);
    return d != null && d.isAfter(new DateTime.now());
  }

  bool isHourValid(String hora) {
    if (hora.isEmpty) return false;
    var d = convertToHour(hora);
    return d != null;
  }

  DateTime convertToDate(String input) {
    try {
      var d = DateFormat("d/M/y").parse(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  DateTime convertToHour(String input) {
    try {
      var d = DateFormat("Hm").parse(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  DateTime convertToDateTime(String inputData) {
    return DateFormat("d/M/y H:m")
        .parse(inputData + " " + _hourController.text);
  }

  String convertToDMYString(DateTime d) {
    try {
      return d.day.toString() +
          "/" +
          d.month.toString() +
          "/" +
          d.year.toString();
    } catch (e) {
      return null;
    }
  }

  String convertToHMString(DateTime d) {
    try {
      return d.hour.toString() + ":" + d.minute.toString();
    } catch (e) {
      return null;
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        backgroundColor: color,
        content: new Text(message),
        duration: Duration(seconds: 3),
      ),
    );
    blocked = false;
  }

  void _submitForm() {
    if (blocked) return;

    blocked = true;
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Por favor, complete todos os campos.');
    } else {
      form.save(); //Executa cada evento "onSaved" dos campos do formulário
      event.createdBy = MyApp.userId();

      if (event.reference == null) {
        Firestore.instance
            .collection(Event.collectionName)
            .add(event.toJson())
            .then(onValue)
            .catchError(showMessage);
      } else {
        event.reference
            .setData(event.toJson())
            .then(onUpdate)
            .catchError(showMessage);
      }
    }
  }

  void onValue(DocumentReference ref) {
    Navigator.pop(context);
  }

  void onUpdate(dynamic yo) {
    Navigator.pop(context);
  }
}
