import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/estilos/fb_icon_icons.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/modulos/usuario/institution.dart';
import 'package:redesign/modulos/usuario/user.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/services/validators.dart';
import 'package:redesign/widgets/standard_button.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as ImageHelper;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoder/geocoder.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
final FirebaseStorage _storage = FirebaseStorage.instance;
StorageReference reference = _storage.ref().child("perfil/" + MyApp.userId() + ".jpg");
bool blocked = false;

class ProfileForm extends StatefulWidget {
  @override
  ProfileFormState createState() => MyApp.user != null ?
    ProfileFormState(user: MyApp.user) : ProfileFormState(institution: MyApp.institution);
}

class ProfileFormState extends State<ProfileForm> {
  Institution institution;
  User user;

  ProfileFormState({this.user, this.institution});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Editar Perfil",
      body: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: user != null ?
            _UsuarioForm(user) : _InstituicaoForm(institution),
      ),
    );
  }
}

class _UsuarioForm extends StatefulWidget {
  final User usuario;

  _UsuarioForm(this.usuario);

  @override
  _UsuarioFormState createState() => _UsuarioFormState(usuario);
}

/// Formulário apenas para usuários normais (pessoas)
/// O formulário para instituição está mais em baixo
class _UsuarioFormState extends State<_UsuarioForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  User usuario;
  Institution instituicaoRelacionada;

  _UsuarioFormState(this.usuario){
    reference.getData(38000).then((value) => setState((){
      imagemAtual = value;
    }));
  }

  List<int> imagemAtual;
  List<int> imagemNova;

  Future getImage() async {
    carregando(true, mensagem: "Enviando foto...");
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(imageFile == null){
      carregando(false);
      return;
    }

    ImageHelper.Image image = ImageHelper.decodeImage(imageFile.readAsBytesSync());

    image = ImageHelper.copyResize(image, 100, 100);

    setState(() {
      imagemNova = ImageHelper.encodeJpg(image, quality: 85);
    });

    if(imagemNova.length > 38000){
      showMessage("Erro: Imagem muito grande");
      imagemNova = null;
      return;
    }

    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putData(imagemNova);
    uploadTask.onComplete.then((s) => uploadFinalizado(imagemNova)).catchError((e) => uploadErro(e));
  }

  void uploadFinalizado(imagem){
    carregando(false);
    showMessage("Foto atualizada", Colors.green);
    setState((){
      imagemNova = imagem;
      imagemAtual = imagem;
    });
    MyApp.imageMemory = imagem;
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
                color: Style.primaryColor,
              ),
              labelText: 'Nome',
            ),
            validator: (val) => val.isEmpty ? 'Nome é obrigatório' : null,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            initialValue: usuario.name,
            onSaved: (val) => usuario.name = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.description,
                color: Style.primaryColor,
              ),
              labelText: 'Descrição',
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            validator: (val) => val.isEmpty ? 'Descrição é obrigatório' : null,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            initialValue: usuario.description,
            onSaved: (val) => usuario.description = val,
          ),
          _buildDropdown(),
          Container(
            padding: EdgeInsets.only(top: 4),
            child: instituicaoRelacionada == null ? Container() :
                GestureDetector(
                  child: Text("Remover seleção",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                  onTap: (){
                    setState(() {
                      usuario.idInstitution = "";
                      instituicaoRelacionada = null;
                    });
                  },
                ),
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
              icon: const Icon(Icons.link,
                color: Style.primaryColor,
              ),
              labelText: 'Site',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            validator: (val) => val.isEmpty ? null : Validators.url(val) ? null : 'Site inválido',
            initialValue: usuario.site,
            onSaved: (val){
              if(!val.startsWith("http")){
                val = "http://" + val;
              }
              usuario.site = val;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(FbIcon.facebook_official,
                color: Style.primaryColor,
              ),
              labelText: 'Facebook',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            validator: (val) => val.isEmpty ? null : Validators.facebookUrl(val) ? null : 'Link do facebook inválido',
            initialValue: usuario.facebook,
            onSaved: (val){
              if(!val.startsWith("http")){
                val = "http://" + val;
              }
              usuario.facebook = val;
            },
          ),
          Container(
              padding: const EdgeInsets.only(top: 20.0),
              child: StandardButton("Salvar", _submitForm,
                  Style.main.primaryColor, Style.lightGrey)
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
      carregando(true);
      form.save(); //Executa cada evento "onSaved" dos campos do formulário
      save(usuario);
    }
  }
  
  save(User usuario){
    usuario.reference.updateData(usuario.toJson())
        .then(saved).catchError(saveError);
  }

  saved(dynamic){
    carregando(false);
    blocked = false;
    Navigator.pop(context);
  }

  saveError(){
    carregando(false);
    blocked = false;
    showMessage("Erro ao atualizar informações");
  }

  Widget _buildDropdown(){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(User.collectionName)
          .where("tipo", isEqualTo: UserType.institution.index)
          .where("ativo", isEqualTo: 1)
          .orderBy("nome")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        if (snapshot.data.documents.length == 0){
          return Text("Não há instituições cadastradas");
        }

        return _buildItems(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildItems(BuildContext context, List<DocumentSnapshot> data){
    return DropdownButtonFormField<Institution>(
      items: data.map( (DocumentSnapshot doc) {
        Institution instituicao = Institution.fromMap(doc.data, reference: doc.reference);

        // Verificar se o tipo do usuário é compatível com a instituição
        if(instituicao.occupation == Occupation.incubadora){
          if(usuario.occupation != Occupation.empreendedor) return null;
        } else if (instituicao.occupation == Occupation.laboratorio){
          if(usuario.occupation != Occupation.professor &&
              usuario.occupation != Occupation.bolsista &&
              usuario.occupation != Occupation.discente) return null;
        } else if (instituicao.occupation == Occupation.escola){
          if(usuario.occupation != Occupation.professor &&
            usuario.occupation != Occupation.aluno) return null;
        }

        if(instituicao.reference.documentID == usuario.idInstitution){
          instituicaoRelacionada = instituicao;
        }

        return DropdownMenuItem<Institution>(
          value: instituicao,
          child: Text(instituicao.name),
          key: ValueKey(instituicao.reference.documentID),
        );
      }).where((d) => d != null).toList(),
      onChanged: (Institution c){
        print("Changed state");
        setState(() {
          instituicaoRelacionada = c;
          usuario.idInstitution = instituicaoRelacionada.reference.documentID;
        });
      },
      value: instituicaoRelacionada,
      decoration: const InputDecoration(
        icon: const Icon(Icons.account_balance,
          color: Style.primaryColor,
        ),
        labelText: 'Instituição',
      ),
    );
  }
}

class _InstituicaoForm extends StatefulWidget {
  final Institution instituicao;

  _InstituicaoForm(this.instituicao);

  @override
  _InstituicaoFormState createState() => _InstituicaoFormState(instituicao);
}

class _InstituicaoFormState extends State<_InstituicaoForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool enderecoMudou = false;

  Institution instituicao;

  _InstituicaoFormState(this.instituicao);

  List<int> imagemAtual;
  List<int> imagemNova;

  Future getImage() async {
    carregando(true, mensagem: "Enviando foto...");
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(imageFile == null){
      carregando(false);
      return;
    }

    ImageHelper.Image image = ImageHelper.decodeImage(imageFile.readAsBytesSync());

    image = ImageHelper.copyResize(image, 100, 100);

    setState(() {
      imagemNova = ImageHelper.encodeJpg(image, quality: 85);
    });

    if(imagemNova.length > 38000){
      showMessage("Erro: Imagem muito grande");
      imagemNova = null;
      return;
    }

    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putData(imagemNova);
    uploadTask.onComplete.then((s) => uploadFinalizado(imagemNova)).catchError((e) => uploadErro(e));
  }

  void uploadFinalizado(imagem){
    carregando(false);
    showMessage("Foto atualizada", Colors.green);
    setState((){
      imagemNova = imagem;
      imagemAtual = imagem;
    });
    MyApp.imageMemory = imagem;
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
                color: Style.primaryColor,
              ),
              labelText: 'Nome',
            ),
            validator: (val) => val.isEmpty ? 'Nome é obrigatório' : null,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            initialValue: instituicao.name,
            onSaved: (val) => instituicao.name = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.description,
                color: Style.primaryColor,
              ),
              labelText: 'Descrição',
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            validator: (val) => val.isEmpty ? 'Descrição é obrigatório' : null,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            initialValue: instituicao.description,
            onSaved: (val) => instituicao.description = val,
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
              icon: const Icon(Icons.link,
                color: Style.primaryColor,
              ),
              labelText: 'Site',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            validator: (val) => val.isEmpty ? null : Validators.url(val) ? null : 'Site inválido',
            initialValue: instituicao.site,
            onSaved: (val){
              if(!val.startsWith("http")){
                val = "http://" + val;
              }
              instituicao.site = val;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(FbIcon.facebook_official,
                color: Style.primaryColor,
              ),
              labelText: 'Facebook',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            validator: (val) => val.isEmpty ? null : Validators.facebookUrl(val) ? null : 'Link do facebook inválido',
            initialValue: instituicao.facebook,
            onSaved: (val){
              if(!val.startsWith("http")){
                val = "http://" + val;
              }
              instituicao.facebook = val;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.location_on,
                color: Style.primaryColor,
              ),
              labelText: 'Endereço (Rua, Número)',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            initialValue: instituicao.address,
            onSaved: (val){
              if(val != instituicao.address) enderecoMudou = true;
              instituicao.address = val;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.location_city,
                color: Style.primaryColor,
              ),
              labelText: 'Cidade',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(40)],
            initialValue: instituicao.city,
            onSaved: (val){
              if(val != instituicao.city) enderecoMudou = true;
              instituicao.city = val; },
          ),
          Container(
              padding: const EdgeInsets.only(top: 20.0),
              child: StandardButton("Salvar", _submitForm,
                  Style.main.primaryColor, Style.lightGrey)
          ),
        ],
      ),
    );
  }

  save(Institution instituicao){
    instituicao.reference.updateData(instituicao.toJson())
        .then(saved).catchError(saveError);
  }

  saved(dynamic){
    carregando(false);
    blocked = false;
    Navigator.pop(context);
  }

  saveError(){
    carregando(false);
    blocked = false;
    showMessage("Erro ao atualizar informações");
  }

  void _submitForm() async{
    if(blocked) return;

    blocked = true;
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Por favor, complete todos os campos.');
      blocked = false;
    } else {
      carregando(true);
      form.save(); //Executa cada evento "onSaved" dos campos do formulário
      try {
        if (enderecoMudou && instituicao.address.isNotEmpty &&
            instituicao.city.isNotEmpty) {
          final query = instituicao.address + " - " + instituicao.city;
          var addresses = await Geocoder.local.findAddressesFromQuery(query);
          var first = addresses.first;
          instituicao.lat = first.coordinates.latitude;
          instituicao.lng = first.coordinates.longitude;
        }
        save(instituicao);
      } catch(e) {
        carregando(false);
        showMessage("Erro ao atualizar informações");
      }
    }
  }
}

void showMessage(String message, [MaterialColor color = Colors.red]) {
  _scaffoldKey.currentState
      .showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
}

void carregando(bool estaCarregando, {String mensagem = "Aguarde"}) {
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
