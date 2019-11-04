import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image/image.dart' as ImageHelper;
import 'package:image_picker/image_picker.dart';
import 'package:redesign/modulos/user/institution.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/services/helper.dart';
import 'package:redesign/services/my_app.dart';
import 'package:redesign/services/validators.dart';
import 'package:redesign/styles/fb_icon_icons.dart';
import 'package:redesign/styles/style.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:redesign/widgets/standard_button.dart';

GlobalKey<ScaffoldState> _scaffoldKey;
final FirebaseStorage _storage = FirebaseStorage.instance;
StorageReference reference =
    _storage.ref().child("perfil/" + MyApp.userId() + ".jpg");
bool blocked = false;

class ProfileForm extends StatefulWidget {
  @override
  ProfileFormState createState() => MyApp.user != null
      ? ProfileFormState(user: MyApp.user)
      : ProfileFormState(institution: MyApp.institution);
}

class ProfileFormState extends State<ProfileForm> {
  Institution institution;
  User user;

  ProfileFormState({this.user, this.institution}) {
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Editar Perfil",
      bodyPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      body: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: user != null ? _UserForm(user) : _InstitutionForm(institution),
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

  // Os controllers repetidos abaixo são necessários para evitar que o valor
  // do campo seja perdido quando o usuario rolar a tela
  TextEditingController _nameController,
      _descController,
      _emailController,
      _siteController,
      _fbController;

  User user;
  Institution relatedInstitution;
  String selectedType;

  _UserFormState(this.user) {
    reference.getData(Helper.maxProfileImageSize).then((value) => setState(() {
          currentImage = value;
        }));
    _nameController = TextEditingController(text: user.name);
    _descController = TextEditingController(text: user.description);
    _emailController = TextEditingController(text: user.email);
    _siteController = TextEditingController(text: user.site);
    _fbController = TextEditingController(text: user.facebook);
  }

  List<int> currentImage;
  List<int> newImage;

  Future getImage() async {
    loading(true, message: "Enviando foto...");
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile == null) {
      loading(false);
      return;
    }

    ImageHelper.Image image =
        ImageHelper.decodeImage(imageFile.readAsBytesSync());

    image = ImageHelper.copyResize(image, width: 100, height: 100);

    setState(() {
      newImage = ImageHelper.encodeJpg(image, quality: 85);
    });

    if (newImage.length > 38000) {
      showMessage("Erro: Imagem muito grande");
      newImage = null;
      return;
    }

    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putData(newImage);
    uploadTask.onComplete
        .then((s) => uploadDone(newImage))
        .catchError((e) => uploadError(e));
  }

  void uploadDone(image) {
    loading(false);
    showMessage("Foto atualizada", Colors.green);
    setState(() {
      newImage = image;
      currentImage = image;
    });
    MyApp.imageMemory = image;
  }

  void uploadError(e) {
    loading(false);
    showMessage("Erro ao atualizar foto");
    setState(() {
      newImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: newImage == null
                                ? currentImage == null
                                    ? AssetImage(
                                        "images/perfil_placeholder.png")
                                    : MemoryImage(currentImage)
                                : MemoryImage(newImage),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(
                      Icons.person,
                      color: Style.primaryColor,
                    ),
                    labelText: 'Nome',
                  ),
                  validator: (val) => val.isEmpty ? 'Nome é obrigatório' : null,
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  onSaved: (val) => user.name = val,
                  controller: _nameController,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(
                      Icons.description,
                      color: Style.primaryColor,
                    ),
                    labelText: 'Descrição',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  validator: (val) =>
                      val.isEmpty ? 'Descrição é obrigatório' : null,
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                  onSaved: (val) => user.description = val,
                  controller: _descController,
                ),
                _buildDropdownAccountType(),
                _buildDropdown(),
                Container(
                  padding: const EdgeInsets.only(top: 4),
                  child: relatedInstitution == null
                      ? Container()
                      : GestureDetector(
                          child: const Text(
                            "Remover seleção",
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                          onTap: () {
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
                  enabled: false,
                  controller: _emailController,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(
                      Icons.link,
                      color: Style.primaryColor,
                    ),
                    labelText: 'Site',
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  validator: (val) => val.isEmpty
                      ? null
                      : Validators.url(val) ? null : 'Site inválido',
                  onSaved: (val) {
                    if (!val.startsWith("http") && val.isNotEmpty) {
                      val = "http://" + val;
                    }
                    user.site = val;
                  },
                  controller: _siteController,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(
                      FbIcon.facebook_official,
                      color: Style.primaryColor,
                    ),
                    labelText: 'Facebook',
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  validator: (val) => val.isEmpty
                      ? null
                      : Validators.facebookUrl(val)
                          ? null
                          : 'Link do facebook inválido',
                  onSaved: (val) {
                    if (!val.startsWith("http") && val.isNotEmpty) {
                      val = "http://" + val;
                    }
                    user.facebook = val;
                  },
                  controller: _fbController,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: StandardButton("Salvar", _submitForm,
                      Style.main.primaryColor, Style.lightGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (blocked) return;

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

  save(User user) {
    user.reference.updateData(user.toJson()).then(saved).catchError(saveError);
  }

  saved(dynamic) {
    loading(false);
    blocked = false;
    if (user.type == UserType.institution) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Tipo de conta alterado'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Por favor, faça login novamente.'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  MyApp.logout(context);
                },
              ),
            ],
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
  }

  saveError(dynamic) {
    loading(false);
    blocked = false;
    showMessage("Erro ao atualizar informações");
  }

  Widget _buildDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(User.collectionName)
          .where("tipo", isEqualTo: UserType.institution.index)
          .where("ativo", isEqualTo: 1)
          .orderBy("nome")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        if (snapshot.data.documents.length == 0) {
          return Text("Não há instituições cadastradas");
        }

        return _buildItems(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildItems(BuildContext context, List<DocumentSnapshot> data) {
    return DropdownButtonFormField<Institution>(
      items: data
          .map((DocumentSnapshot doc) {
            Institution institution =
                Institution.fromMap(doc.data, reference: doc.reference);

            // Verificar se o tipo do usuário é compatível com a instituição
            if (institution.occupation == Occupation.incubadora) {
              if (user.occupation != Occupation.empreendedor) return null;
            } else if (institution.occupation == Occupation.laboratorio) {
              if (user.occupation != Occupation.professor &&
                  user.occupation != Occupation.bolsista &&
                  user.occupation != Occupation.discente) return null;
            } else if (institution.occupation == Occupation.escola) {
              if (user.occupation != Occupation.professor &&
                  user.occupation != Occupation.aluno) return null;
            }

            if (institution.reference.documentID == user.idInstitution) {
              relatedInstitution = institution;
            }

            return DropdownMenuItem<Institution>(
              value: institution,
              child: Text(institution.name),
              key: ValueKey(institution.reference.documentID),
            );
          })
          .where((d) => d != null)
          .toList(),
      onChanged: (Institution c) {
        print("Changed state");
        setState(() {
          relatedInstitution = c;
          user.idInstitution = relatedInstitution.reference.documentID;
        });
      },
      value: relatedInstitution,
      decoration: const InputDecoration(
        icon: const Icon(
          Icons.account_balance,
          color: Style.primaryColor,
        ),
        labelText: 'Instituição',
      ),
    );
  }

  Widget _buildDropdownAccountType() {
    return DropdownButtonFormField<String>(
      items: Occupation.all
          .map((String type) {
            if (type == user.occupation) {
              selectedType = type;
            }

            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
              key: ValueKey(type),
            );
          })
          .where((d) => d != null)
          .toList(),
      onChanged: (String c) {
        print("Changed state");
        setState(() {
          selectedType = c;
          user.occupation = c;
          user.type = Helper.getTypeFromOccupation(c);
        });
      },
      value: selectedType,
      decoration: const InputDecoration(
        icon: const Icon(
          Icons.account_box,
          color: Style.primaryColor,
        ),
        labelText: 'Tipo de Conta',
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
  String selectedType;

  // Os controllers repetidos abaixo são necessários para evitar que o valor
  // do campo seja perdido quando o usuario rolar a tela
  TextEditingController _nameController,
      _descController,
      _emailController,
      _siteController,
      _fbController,
      _addrController,
      _cityController;

  _InstitutionFormState(this.institution) {
    reference
        .getData(Helper.maxProfileImageSize)
        .then((value) => setState(() {
              currentImage = value;
            }))
        .catchError((e) {});
    _nameController = TextEditingController(text: institution.name);
    _descController = TextEditingController(text: institution.description);
    _emailController = TextEditingController(text: institution.email);
    _siteController = TextEditingController(text: institution.site);
    _fbController = TextEditingController(text: institution.facebook);
    _addrController = TextEditingController(text: institution.address);
    _cityController = TextEditingController(text: institution.city);
  }

  List<int> currentImage;
  List<int> newImage;

  Future getImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile == null) {
      loading(false);
      return;
    }

    loading(true, message: "Enviando foto...");

    ImageHelper.Image image =
        ImageHelper.decodeImage(imageFile.readAsBytesSync());

    image = ImageHelper.copyResize(image, width: 100, height: 100);

    setState(() {
      newImage = ImageHelper.encodeJpg(image, quality: 85);
    });

    if (newImage.length > 38000) {
      showMessage("Erro: Imagem muito grande");
      newImage = null;
      return;
    }

    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putData(newImage);
    uploadTask.onComplete
        .then((s) => uploadDone(newImage))
        .catchError((e) => uploadError(e));
  }

  void uploadDone(image) {
    loading(false);
    showMessage("Foto atualizada", Colors.green);
    setState(() {
      newImage = image;
      currentImage = image;
    });
    MyApp.imageMemory = image;
  }

  void uploadError(e) {
    loading(false);
    showMessage("Erro ao atualizar foto");
    setState(() {
      newImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: newImage == null
                                ? currentImage == null
                                    ? AssetImage(
                                        "images/perfil_placeholder.png")
                                    : MemoryImage(currentImage)
                                : MemoryImage(newImage),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(
                      Icons.people,
                      color: Style.primaryColor,
                    ),
                    labelText: 'Nome',
                  ),
                  validator: (val) => val.isEmpty ? 'Nome é obrigatório' : null,
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  controller: _nameController,
                  onSaved: (val) => institution.name = val,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(
                      Icons.description,
                      color: Style.primaryColor,
                    ),
                    labelText: 'Descrição',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  validator: (val) =>
                      val.isEmpty ? 'Descrição é obrigatório' : null,
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                  controller: _descController,
                  onSaved: (val) => institution.description = val,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.email),
                    labelText: 'Email (não editável)',
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                  controller: _emailController,
                  enabled: false,
                ),
                _buildDropdownAccountType(),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(
                      Icons.link,
                      color: Style.primaryColor,
                    ),
                    labelText: 'Site',
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  validator: (val) => val.isEmpty
                      ? null
                      : Validators.url(val) ? null : 'Site inválido',
                  controller: _siteController,
                  onSaved: (val) {
                    if (!val.startsWith("http") && val.isNotEmpty) {
                      val = "http://" + val;
                    }
                    institution.site = val;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(
                      FbIcon.facebook_official,
                      color: Style.primaryColor,
                    ),
                    labelText: 'Facebook',
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  validator: (val) => val.isEmpty
                      ? null
                      : Validators.facebookUrl(val)
                          ? null
                          : 'Link do facebook inválido',
                  controller: _fbController,
                  onSaved: (val) {
                    if (!val.startsWith("http") && val.isNotEmpty) {
                      val = "http://" + val;
                    }
                    institution.facebook = val;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(
                      Icons.location_on,
                      color: Style.primaryColor,
                    ),
                    labelText: 'Endereço (Rua, Número)',
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  controller: _addrController,
                  onSaved: (val) {
                    if (val != institution.address) addressChanged = true;
                    institution.address = val;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(
                      Icons.location_city,
                      color: Style.primaryColor,
                    ),
                    labelText: 'Cidade',
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                  controller: _cityController,
                  onSaved: (val) {
                    if (val != institution.city) addressChanged = true;
                    institution.city = val;
                  },
                ),
                Container(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: StandardButton("Salvar", _submitForm,
                        Style.main.primaryColor, Style.lightGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  save(Institution institution) {
    institution.reference
        .updateData(institution.toJson())
        .then(saved)
        .catchError(saveError);
  }

  saved(dynamic) {
    loading(false);
    blocked = false;
    if (institution.type == UserType.person) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Tipo de conta alterado'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Por favor, faça login novamente.'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  MyApp.logout(context);
                },
              ),
            ],
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
  }

  saveError(e) {
    loading(false);
    blocked = false;
    showMessage("Erro ao atualizar informações");
    print(e);
  }

  Widget _buildDropdownAccountType() {
    return DropdownButtonFormField<String>(
      items: Occupation.all
          .map((String type) {
            if (type == institution.occupation) {
              selectedType = type;
            }

            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
              key: ValueKey(type),
            );
          })
          .where((d) => d != null)
          .toList(),
      onChanged: (String c) {
        print("Changed state");
        setState(() {
          selectedType = c;
          institution.occupation = c;
          institution.type = Helper.getTypeFromOccupation(c);
        });
      },
      value: selectedType,
      decoration: const InputDecoration(
        icon: const Icon(
          Icons.account_box,
          color: Style.primaryColor,
        ),
        labelText: 'Tipo de Conta',
      ),
    );
  }

  void _submitForm() async {
    if (blocked) return;

    blocked = true;
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Por favor, complete todos os campos.');
      blocked = false;
    } else {
      loading(true);
      form.save(); //Executa cada evento "onSaved" dos campos do formulário
      try {
        if (addressChanged &&
            institution.address.isNotEmpty &&
            institution.city.isNotEmpty) {
          final query = institution.address + " - " + institution.city;
          var addresses =
              await Geocoder.google("***REMOVED***")
                  .findAddressesFromQuery(query);
          var first = addresses.first;
          institution.lat = first.coordinates.latitude;
          institution.lng = first.coordinates.longitude;
        }
        save(institution);
      } catch (e) {
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
  if (isLoading) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        backgroundColor: Style.primaryColor,
        content: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            CircularProgressIndicator(
              backgroundColor: Colors.black45,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(message),
            )
          ],
        ),
      ),
    );
  } else {
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }
}
