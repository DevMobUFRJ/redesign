import 'dart:io';

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
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as ImageHelper;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoder/geocoder.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
final FirebaseStorage _storage = FirebaseStorage.instance;
StorageReference reference = _storage.ref().child("perfil/" + MeuApp.userId() + ".jpg");
bool blocked = false;

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

  Usuario usuario;

  _UsuarioFormState(this.usuario){
    reference.getData(38000).then((value) => setState((){
      imagemAtual = value;
    }));
  }

  List<int> imagemAtual;
  List<int> imagemNova;

  Future getImage() async {
    carregando(true, mensagem: "Fazendo upload da imagem...");
    File image_file = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(image_file == null){
      carregando(false);
      return;
    }

    ImageHelper.Image image = ImageHelper.decodeImage(image_file.readAsBytesSync());

    image = ImageHelper.copyResize(image, 100, 100);

    setState(() {
      imagemNova = ImageHelper.encodeJpg(image, quality: 90);
    });

    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putData(imagemNova);
    uploadTask.onComplete.then((s) => uploadFinalizado(imagemNova)).catchError((e) => uploadErro(e));
  }

  void uploadFinalizado(imagem){
    carregando(false);
    showMessage("Upload finalizado", Colors.green);
    setState((){
      imagemNova = imagem;
      imagemAtual = imagem;
    });
    MeuApp.imagemMemory = imagem;
  }

  void uploadErro(e){
    carregando(false);
    showMessage("Erro ao atualizar foto");
    setState((){
      imagemNova = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: ListView(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: (){ getImage(); },
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      //TODO Imagem do usuário if tem imagem. Else, placeholder.
                      image: imagemNova == null ? imagemAtual == null ?
                          AssetImage("images/perfil_placeholder.png") :
                          MemoryImage(imagemAtual):
                          MemoryImage(imagemNova),
                    )
                  ),
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.person,
                color: Tema.primaryColor,
              ),
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
              icon: const Icon(Icons.description,
                color: Tema.primaryColor,
              ),
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
              icon: const Icon(Icons.link,
                color: Tema.primaryColor,
              ),
              labelText: 'Site',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            validator: (val) => val.isEmpty ? null : Validadores.url(val) ? null : 'Site inválido',
            initialValue: usuario.site,
            onSaved: (val) => usuario.site = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.face,
                color: Tema.primaryColor,
              ),
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

  void _submitForm() {
    if(blocked) return;

    blocked = true;
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Por favor, complete todos os campos.');
      blocked = false;
    } else {
      form.save(); //Executa cada evento "onSaved" dos campos do formulário
      save(usuario);
    }
  }
  
  save(Usuario usuario){
    usuario.reference.updateData(usuario.toJson())
        .then(saved); //TODO pegar o erro
    blocked = false;
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
  bool enderecoMudou = false;

  Instituicao instituicao;

  _InstituicaoFormState(this.instituicao);

  List<int> imagemAtual;
  List<int> imagemNova;

  Future getImage() async {
    carregando(true, mensagem: "Fazendo upload da imagem...");
    File image_file = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(image_file == null){
      carregando(false);
      return;
    }

    ImageHelper.Image image = ImageHelper.decodeImage(image_file.readAsBytesSync());

    image = ImageHelper.copyResize(image, 100, 100);

    setState(() {
      imagemNova = ImageHelper.encodeJpg(image, quality: 90);
    });

    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putData(imagemNova);
    uploadTask.onComplete.then((s) => uploadFinalizado(imagemNova)).catchError((e) => uploadErro(e));
  }

  void uploadFinalizado(imagem){
    carregando(false);
    showMessage("Upload finalizado", Colors.green);
    setState((){
      imagemNova = imagem;
      imagemAtual = imagem;
    });
    MeuApp.imagemMemory = imagem;
  }

  void uploadErro(e){
    carregando(false);
    showMessage("Erro ao atualizar foto");
    setState((){
      imagemNova = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: ListView(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: (){ getImage(); },
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        //TODO Imagem do usuário if tem imagem. Else, placeholder.
                        image: imagemNova == null ? imagemAtual == null ?
                        AssetImage("images/perfil_placeholder.png") :
                        MemoryImage(imagemAtual):
                        MemoryImage(imagemNova),
                      )
                  ),
                ),
              ),
            ],
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.people,
                color: Tema.primaryColor,
              ),
              labelText: 'Nome',
            ),
            validator: (val) => val.isEmpty ? 'Nome é obrigatório' : null,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            initialValue: instituicao.nome,
            onSaved: (val) => instituicao.nome = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.email),
              labelText: 'Email (não editável)',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            initialValue: instituicao.email,
            enabled: false,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.description,
                color: Tema.primaryColor,
              ),
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
              icon: const Icon(Icons.link,
                color: Tema.primaryColor,
              ),
              labelText: 'Site',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            validator: (val) => val.isEmpty ? null : Validadores.url(val) ? null : 'Site inválido',
            initialValue: instituicao.site,
            onSaved: (val) => instituicao.site = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.face,
                color: Tema.primaryColor,
              ),
              labelText: 'Facebook',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            validator: (val) => val.isEmpty ? null : Validadores.facebookUrl(val) ? null : 'Link do facebook inválido',
            initialValue: instituicao.facebook,
            onSaved: (val) => instituicao.facebook = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.location_on,
                color: Tema.primaryColor,
              ),
              labelText: 'Endereço (Rua, Número)',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            initialValue: instituicao.endereco,
            onSaved: (val){
              if(val != instituicao.endereco) enderecoMudou = true;
              instituicao.endereco = val;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.location_city,
                color: Tema.primaryColor,
              ),
              labelText: 'Cidade',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(40)],
            initialValue: instituicao.cidade,
            onSaved: (val){
              if(val != instituicao.cidade) enderecoMudou = true;
              instituicao.cidade = val; },
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

  save(Instituicao instituicao){
    instituicao.reference.updateData(instituicao.toJson())
        .then(saved); //TODO pegar o erro
    blocked = false;
  }

  saved(dynamic){
    Navigator.pop(context);
  }

  void _submitForm() async{
    if(blocked) return;

    blocked = true;
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Por favor, complete todos os campos.');
      blocked = false;
    } else {
      form.save(); //Executa cada evento "onSaved" dos campos do formulário
      if(enderecoMudou && instituicao.endereco.isNotEmpty && instituicao.cidade.isNotEmpty){
        debugPrint("Achando endereço...");
        final query = instituicao.endereco + " - " + instituicao.cidade;
        var addresses = await Geocoder.local.findAddressesFromQuery(query);
        var first = addresses.first;
        instituicao.lat = first.coordinates.latitude;
        instituicao.lng = first.coordinates.longitude;
        debugPrint("Achou:");
        debugPrint(first.addressLine);
      }
      save(instituicao);
    }
  }
}

void showMessage(String message, [MaterialColor color = Colors.red]) {
  _scaffoldKey.currentState
      .showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
}

void carregando(bool estaCarregando, {String mensagem = ""}) {
  blocked = !estaCarregando;
  if(estaCarregando) {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber,
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(),
              Text(" " + mensagem)
            ],
          ),
        ));
  } else {
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }
}
