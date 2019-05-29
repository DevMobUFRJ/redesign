import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/user/institution.dart';
import 'package:redesign/modulos/user/profile_institution.dart';
import 'package:redesign/modulos/user/profile_person.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/services/helper.dart';
import 'package:redesign/services/my_app.dart';

/// Idealmente, aqui ficam todos os widgets padronizados para lidar com dados
/// que precisam ser buscados de forma asíncrona do firebase.

/// [NameTextAsync] Recebe o ID do usuário como parâmetro pra obter o nome.
/// Gera um Stateful Text com o nome do usuário.
class NameTextAsync extends StatefulWidget {
  final String userId;
  final TextStyle style;
  final String prefix;

  const NameTextAsync(this.userId, this.style, {this.prefix = "por"});

  @override
  _NameTextState createState() => _NameTextState(userId, prefix);
}

class _NameTextState extends State<NameTextAsync> {
  final String user;
  final String prefix;
  String nome = "";

  _NameTextState(this.user, this.prefix){
    if(user != null && user.isNotEmpty){
      // Dentro do construtor pois se fosse no build seria repetido toda hora.
      DocumentReference ref = Firestore.instance.collection(
          User.collectionName).document(user);
      try {
        ref.get().then(updateName).catchError((e){});
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    String text = "";
    if(nome != ""){
      if(prefix.isNotEmpty){
        text = prefix + " ";
      }
      text += nome;
    }

    return Text(text, style: widget.style, overflow: TextOverflow.clip, maxLines: 1,);
  }

  updateName(DocumentSnapshot user){
    try{
      String newName = user.data['nome'];
      if(newName != null)
        setState(() {
          nome = newName;
        });
    } catch(e){}
  }
}

class CircleAvatarAsync extends StatefulWidget {
  final String userId;
  final double radius;
  final bool clickable;

  CircleAvatarAsync(this.userId, {this.radius=20.0, this.clickable=false});

  @override
  _CircleAvatarAsyncState createState() => _CircleAvatarAsyncState();
}

class _CircleAvatarAsyncState extends State<CircleAvatarAsync> {
  List<int> image;
  User user;

  _CircleAvatarAsyncState();

  @override
  void initState(){
    super.initState();
    if(image == null && widget.userId != null){
      if(widget.userId == MyApp.userId()){
        image = MyApp.imageMemory;
      } else {
        FirebaseStorage.instance.ref()
            .child("perfil/" + widget.userId + ".jpg")
            .getData(Helper.maxProfileImageSize).then(receivedProfilePhoto)
            .catchError((e){});
        if(widget.clickable != null) {
          Firestore.instance.collection(User.collectionName).document(
              widget.userId).get().then(gotUser)
              .catchError((e){});
        }
      }
    }
  }

  receivedProfilePhoto(List<int> img){
    setState(() {
      image = img;
    });
  }

  gotUser(DocumentSnapshot doc){
    if(doc.data['tipo'] == UserType.institution.index){
      user = Institution.fromMap(doc.data, reference: doc.reference);
    } else {
      user = User.fromMap(doc.data, reference: doc.reference);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(widget.userId + "circleavatarasync"),
      child: CircleAvatar(
        backgroundImage: image == null ?
            AssetImage("images/perfil_placeholder.png")
            : MemoryImage(image),
        radius: widget.radius,
      ),
      onTap: (){
        if(user != null && this.widget.clickable){
          if(user.type == UserType.institution){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileInstitution(user))
            );
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePerson(user))
            );
          }
        }
      },
    );
  }

}