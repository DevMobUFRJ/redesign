import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/tema.dart';
import 'package:redesign/modulos/usuario/instituicao.dart';
import 'package:redesign/modulos/usuario/usuario.dart';
import 'package:redesign/servicos/meu_app.dart';
import 'package:redesign/servicos/validadores.dart';
import 'package:redesign/widgets/botao_padrao.dart';
import 'package:redesign/widgets/tela_base.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class PerfilForm extends StatefulWidget {
  @override
  PerfilFormState createState() => MeuApp.usuario != null ?
    PerfilFormState(usuario: MeuApp.usuario) : PerfilFormState(instituicao: MeuApp.instituicao);
}

class PerfilFormState extends State<PerfilForm> {
  Instituicao instituicao;
  Usuario usuario;

  PerfilFormState({this.usuario, this.instituicao});

  @override
  Widget build(BuildContext context) {
    return TelaBase(
      title: "Editar Perfil",
      body: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: usuario != null ?
            _UsuarioForm(usuario) : _InstituicaoForm(instituicao),
      ),
    );
  }
}

class _UsuarioForm extends StatefulWidget {
  final Usuario usuario;

  _UsuarioForm(this.usuario);

  @override
  _UsuarioFormState createState() => _UsuarioFormState(usuario);
}

/// Formulário apenas para usuários normais (pessoas)
/// O formulário para instituição está mais em baixo
class _UsuarioFormState extends State<_UsuarioForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool blocked = false;

  Usuario usuario;

  _UsuarioFormState(this.usuario);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: ListView(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.person),
              labelText: 'Nome',
            ),
            validator: (val) => val.isEmpty ? 'Nome é obrigatório' : null,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            initialValue: usuario.nome,
            onSaved: (val) => usuario.nome = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.email),
              labelText: 'Email (não editável)',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            initialValue: usuario.email,
            enabled: false,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.description),
              labelText: 'Descrição',
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            validator: (val) => val.isEmpty ? 'Descrição é obrigatório' : null,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            initialValue: usuario.descricao,
            onSaved: (val) => usuario.descricao = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.link),
              labelText: 'Site',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            validator: (val) => val.isEmpty ? null : Validadores.url(val) ? null : 'Site inválido',
            initialValue: usuario.site,
            onSaved: (val) => usuario.site = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.face),
              labelText: 'Facebook',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            validator: (val) => val.isEmpty ? null : Validadores.facebookUrl(val) ? null : 'Link do facebook inválido',
            initialValue: usuario.facebook,
            onSaved: (val) => usuario.facebook = val,
          ),
          Container(
              padding: const EdgeInsets.only(top: 20.0),
              child: BotaoPadrao("Salvar", _submitForm,
                  Tema.principal.primaryColor, Tema.cinzaClaro)
          ),
        ],
      ),
    );
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    blocked = false;
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
  }

  void _submitForm() {
    if(blocked) return;

    blocked = true;
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Por favor, complete todos os campos.');
    } else {
      form.save(); //Executa cada evento "onSaved" dos campos do formulário
      save(usuario);
    }
  }
  
  save(Usuario usuario){
    usuario.reference.updateData(usuario.toJson())
        .then(saved); //TODO pegar o erro
  }

  saved(dynamic){
    Navigator.pop(context);
  }
}

class _InstituicaoForm extends StatefulWidget {
  final Instituicao instituicao;

  _InstituicaoForm(this.instituicao);

  @override
  _InstituicaoFormState createState() => _InstituicaoFormState(instituicao);
}

class _InstituicaoFormState extends State<_InstituicaoForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool blocked = false;

  Instituicao instituicao;

  _InstituicaoFormState(this.instituicao);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: ListView(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.people),
              labelText: 'Nome',
            ),
            validator: (val) => val.isEmpty ? 'Nome é obrigatório' : null,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            initialValue: instituicao.nome,
            onSaved: (val) => instituicao.nome = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.description),
              labelText: 'Descrição',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            initialValue: instituicao.email,
            enabled: false,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.description),
              labelText: 'Descrição',
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            validator: (val) => val.isEmpty ? 'Descrição é obrigatório' : null,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            initialValue: instituicao.descricao,
            onSaved: (val) => instituicao.descricao = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.person),
              labelText: 'Site',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            validator: (val) => val.isEmpty ? null : Validadores.url(val) ? null : 'Site inválido',
            initialValue: instituicao.site,
            onSaved: (val) => instituicao.site = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.face),
              labelText: 'Site',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            validator: (val) => val.isEmpty ? null : Validadores.facebookUrl(val) ? null : 'Link do facebook inválido',
            initialValue: instituicao.facebook,
            onSaved: (val) => instituicao.facebook = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.location_on),
              labelText: 'Endereço',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            initialValue: instituicao.endereco,
            onSaved: (val) => instituicao.endereco = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.location_city),
              labelText: 'Cidade',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(40)],
            initialValue: instituicao.cidade,
            onSaved: (val) => instituicao.cidade = val,
          ),
          Container(
              padding: const EdgeInsets.only(top: 20.0),
              child: BotaoPadrao("Salvar", _submitForm,
                  Tema.principal.primaryColor, Tema.cinzaClaro)
          ),
        ],
      ),
    );
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    blocked = false;
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
  }

  save(Instituicao instituicao){
    instituicao.reference.updateData(instituicao.toJson())
        .then(saved); //TODO pegar o erro
  }

  saved(DocumentReference doc){
    Navigator.pop(context);
  }

  void _submitForm() {
    if(blocked) return;

    blocked = true;
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Por favor, complete todos os campos.');
    } else {
      form.save(); //Executa cada evento "onSaved" dos campos do formulário
      save(instituicao);
    }
  }
}