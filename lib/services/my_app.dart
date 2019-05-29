import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:redesign/modulos/user/institution.dart';
import 'package:redesign/modulos/user/profile_institution.dart';
import 'package:redesign/modulos/user/profile_person.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/services/helper.dart';

class MyApp {
  static FirebaseUser firebaseUser;
  static List<int> imageMemory;
  /// Deve usar apenas um dos campos abaixo, usuario ou instituicao
  /// de acordo com o tipo do firebaseUser;
  static User user;
  static Institution institution;

  static bool active() => firebaseUser != null ? (user != null ? user.isActive() : institution.isActive()) : false;
  static String userId() => firebaseUser != null ? firebaseUser.uid : null;
  static String name() => user != null ? user.name : institution != null ? institution.name : "";
  static String occupation() => user != null ? user.occupation : institution != null ? institution.occupation : "";
  static bool isStudent() => user != null && user.occupation == Occupation.aluno; //Alunos tem regras especiais no app

  static bool isLabDis() => institution != null &&
      firebaseUser.email == Helper.emailLabdis;

  /// Retorna uma função a ser
  static void gotoProfile(BuildContext context){
    if(user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePerson(user),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileInstitution(institution),
        ),
      );
    }
  }

  static void startup(){
    imageMemory = null;
    updateImage();
  }

  static void setUser(User user){
    if(user.type == UserType.institution){
      MyApp.institution = user;
      MyApp.user = null;
    } else {
      MyApp.user = user;
      MyApp.institution = null;
    }
  }

  static void logout(BuildContext context){
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
    MyApp.firebaseUser = null;
    MyApp.user = null;
    MyApp.institution = null;
    MyApp.imageMemory = null;
  }

  static void updateImage(){
    if(imageMemory == null && userId() != null){
      FirebaseStorage.instance.ref().child("perfil/" + userId() + ".jpg")
          .getData(Helper.maxProfileImageSize)
          .then(saveImage)
          .catchError((e){});
    }
  }

  static void saveImage(List<int> bytes){
    imageMemory = bytes;
  }

  static DocumentReference getUserReference(){
    if(user != null){
      return user.reference;
    } else if (institution != null){
      return institution.reference;
    }
    return null;
  }
}