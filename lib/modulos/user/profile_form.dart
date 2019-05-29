import 'dart:io';
import 'dart:ui' as prefix0;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/services/helper.dart';
import 'package:redesign/styles/fb_icon_icons.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/modulos/user/institution.dart';
import 'package:redesign/modulos/user/user.dart';
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
            _UserForm(user) : _InstitutionForm(institution),
      ),
    );
  }
}

class _UserForm extends StatefulWidget {
  final User user;

  _UserForm(this.user);

  @override
  _UserFormState createState() => _UserFormState(user);
}

/// Formulário apenas para usuários normais (pessoas)
/// O formulário para instituição está mais em baixo
class _UserFormState extends State<_UserForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  User user;
  Institution relatedInstitution;

  _UserFormState(this.user){
    reference.getData(Helper.maxProfileImageSize).then((value) => setState((){
      currentImage = value;
    }));
  }

  List<int> currentImage;
  List<int> newImage;

  Future getImage() async {
    loading(true, message: "Enviando foto...");
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(imageFile == null){
      loading(false);
      return;
    }

    ImageHelper.Image image = ImageHelper.decodeImage(imageFile.readAsBytesSync());

    image = ImageHelper.copyResize(image, width: 100, height: 100);

    setState(() {
      newImage = ImageHelper.encodeJpg(image, quality: 85);
    });

    if(newImage.length > 38000){
      showMessage("Erro: Imagem muito grande");
      newImage = null;
      return;
    }

    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putData(newImage);
    uploadTask.onComplete.then((s) => uploadDone(newImage)).catchError((e) => uploadError(e));
  }

  void uploadDone(image){
    loading(false);
    showMessage("Foto atualizada", Colors.green);
    setState((){
      newImage = image;
      currentImage = image;
    });
    MyApp.imageMemory = image;
  }

  void uploadError(e){
    loading(false);
    showMessage("Erro ao atualizar foto");
    setState((){
      newImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
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
                      image: newImage == null ? currentImage == null ?
                          AssetImage("images/perfil_placeholder.png") :
                          MemoryImage(currentImage):
                          MemoryImage(newImage),
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
            initialValue: user.name,
            onSaved: (val) => user.name = val,
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
            initialValue: user.description,
            onSaved: (val) => user.description = val,
          ),
          _buildDropdown(),
          Container(
            padding: EdgeInsets.only(top: 4),
            child: relatedInstitution == null ? Container() :
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
                      user.idInstitution = "";
                      relatedInstitution = null;
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
            initialValue: user.email,
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
            initialValue: user.site,
            onSaved: (val){
              if(!val.startsWith("http") && val.isNotEmpty){
                val = "http://" + val;
              }
              user.site = val;
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
            initialValue: user.facebook,
            onSaved: (val){
              if(!val.startsWith("http") && val.isNotEmpty){
                val = "http://" + val;
              }
              user.facebook = val;
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
      loading(true);
      form.save(); //Executa cada evento "onSaved" dos campos do formulário
      save(user);
    }
  }
  
  save(User user){
    user.reference.updateData(user.toJson())
        .then(saved).catchError(saveError);
  }

  saved(dynamic){
    loading(false);
    blocked = false;
    Navigator.pop(context);
  }

  saveError(){
    loading(false);
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
        Institution institution = Institution.fromMap(doc.data, reference: doc.reference);

        // Verificar se o tipo do usuário é compatível com a instituição
        if(institution.occupation == Occupation.incubadora){
          if(user.occupation != Occupation.empreendedor) return null;
        } else if (institution.occupation == Occupation.laboratorio){
          if(user.occupation != Occupation.professor &&
              user.occupation != Occupation.bolsista &&
              user.occupation != Occupation.discente) return null;
        } else if (institution.occupation == Occupation.escola){
          if(user.occupation != Occupation.professor &&
            user.occupation != Occupation.aluno) return null;
        }

        if(institution.reference.documentID == user.idInstitution){
          relatedInstitution = institution;
        }

        return DropdownMenuItem<Institution>(
          value: institution,
          child: Text(institution.name),
          key: ValueKey(institution.reference.documentID),
        );
      }).where((d) => d != null).toList(),
      onChanged: (Institution c){
        print("Changed state");
        setState(() {
          relatedInstitution = c;
          user.idInstitution = relatedInstitution.reference.documentID;
        });
      },
      value: relatedInstitution,
      decoration: const InputDecoration(
        icon: const Icon(Icons.account_balance,
          color: Style.primaryColor,
        ),
        labelText: 'Instituição',
      ),
    );
  }
}

class _InstitutionForm extends StatefulWidget {
  final Institution institution;

  _InstitutionForm(this.institution);

  @override
  _InstitutionFormState createState() => _InstitutionFormState(institution);
}

class _InstitutionFormState extends State<_InstitutionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool addressChanged = false;

  Institution institution;

  _InstitutionFormState(this.institution){
      reference.getData(Helper.maxProfileImageSize).then((value) => setState((){
        currentImage = value;
      }));
  }

  List<int> currentImage;
  List<int> newImage;

  Future getImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(imageFile == null){
      loading(false);
      return;
    }

    loading(true, message: "Enviando foto...");

    ImageHelper.Image image = ImageHelper.decodeImage(imageFile.readAsBytesSync());

    image = ImageHelper.copyResize(image, width: 100, height: 100);

    setState(() {
      newImage = ImageHelper.encodeJpg(image, quality: 85);
    });

    if(newImage.length > 38000){
      showMessage("Erro: Imagem muito grande");
      newImage = null;
      return;
    }

    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putData(newImage);
    uploadTask.onComplete.then((s) => uploadDone(newImage)).catchError((e) => uploadError(e));
  }

  void uploadDone(image){
    loading(false);
    showMessage("Foto atualizada", Colors.green);
    setState((){
      newImage = image;
      currentImage = image;
    });
    MyApp.imageMemory = image;
  }

  void uploadError(e){
    loading(false);
    showMessage("Erro ao atualizar foto");
    setState((){
      newImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
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
                        image: newImage == null ? currentImage == null ?
                        AssetImage("images/perfil_placeholder.png") :
                        MemoryImage(currentImage):
                        MemoryImage(newImage),
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
            initialValue: institution.name,
            onSaved: (val) => institution.name = val,
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
            initialValue: institution.description,
            onSaved: (val) => institution.description = val,
          ),
          TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.email),
              labelText: 'Email (não editável)',
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            initialValue: institution.email,
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
            initialValue: institution.site,
            onSaved: (val){
              if(!val.startsWith("http") && val.isNotEmpty){
                val = "http://" + val;
              }
              institution.site = val;
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
            initialValue: institution.facebook,
            onSaved: (val){
              if(!val.startsWith("http") && val.isNotEmpty){
                val = "http://" + val;
              }
              institution.facebook = val;
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
            initialValue: institution.address,
            onSaved: (val){
              if(val != institution.address) addressChanged = true;
              institution.address = val;
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
            initialValue: institution.city,
            onSaved: (val){
              if(val != institution.city) addressChanged = true;
              institution.city = val;
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

  save(Institution institution){
    institution.reference.updateData(institution.toJson())
        .then(saved).catchError(saveError);
  }

  saved(dynamic){
    loading(false);
    blocked = false;
    Navigator.pop(context);
  }

  saveError(e){
    loading(false);
    blocked = false;
    showMessage("Erro ao atualizar informações");
    print(e);
  }

  void _submitForm() async{
    if(blocked) return;

    blocked = true;
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Por favor, complete todos os campos.');
      blocked = false;
    } else {
      loading(true);
      form.save(); //Executa cada evento "onSaved" dos campos do formulário
      try {
        if (addressChanged && institution.address.isNotEmpty &&
            institution.city.isNotEmpty) {
          final query = institution.address + " - " + institution.city;
          var addresses = await Geocoder.local.findAddressesFromQuery(query);
          var first = addresses.first;
          institution.lat = first.coordinates.latitude;
          institution.lng = first.coordinates.longitude;
        }
        save(institution);
      } catch(e) {
        loading(false);
        showMessage("Erro ao atualizar informações");
        print(e);
      }
    }
  }
}

void showMessage(String message, [MaterialColor color = Colors.red]) {
  _scaffoldKey.currentState
      .showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
}

void loading(bool isLoading, {String message = "Aguarde"}) {
  blocked = isLoading;
  if(isLoading) {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber,
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text( message),
              )
            ],
          ),
        ));
  } else {
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }
}
