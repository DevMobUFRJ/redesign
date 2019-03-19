import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/modulos/user/institution.dart';
import 'package:redesign/modulos/user/profile_institution.dart';
import 'package:redesign/modulos/user/profile_person.dart';
import 'package:redesign/modulos/user/user.dart';
import 'package:redesign/services/my_app.dart';

/// Idealmente, aqui ficam todos os widgets padronizados para lidar com dados
/// que precisam ser buscados de forma asíncrona do firebase.

/// [NomeTextAsync] Recebe o ID do usuário como parâmetro pra obter o nome.
/// Gera um Stateful Text com o nome do usuário.
class NomeTextAsync extends StatefulWidget {
  final String idUsuario;
  final TextStyle style;
  final String prefixo;

  const NomeTextAsync(this.idUsuario, this.style, {this.prefixo = "por"});

  @override
  _NomeTextState createState() => _NomeTextState(idUsuario, prefixo);
}

class _NomeTextState extends State<NomeTextAsync> {
  final String usuario;
//  TextStyle style;
  final String prefixo;
  String nome = "";

  _NomeTextState(this.usuario, this.prefixo){
    if(usuario != null && usuario.isNotEmpty){
      // Dentro do construtor pois se fosse no build seria repetido toda hora.
      DocumentReference ref = Firestore.instance.collection(
          User.collectionName).document(usuario);
      try {
        ref.get().then(atualizarNome).catchError((e){});
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    String texto = "";
    if(nome != ""){
      if(prefixo.isNotEmpty){
        texto = prefixo + " ";
      }
      texto += nome;
    }

    return Text(texto, style: widget.style, overflow: TextOverflow.clip, maxLines: 1,);
  }

  atualizarNome(DocumentSnapshot user){
    try{
      String nomeNovo = user.data['nome'];
      if(nomeNovo != null)
        setState(() {
          nome = nomeNovo;
        });
    } catch(e){}
  }
}

class CircleAvatarAsync extends StatefulWidget {
  final String idUsuario;
  final double radius;
  final bool clicavel;

  CircleAvatarAsync(this.idUsuario, {this.radius=20.0, this.clicavel=false});

  @override
  _CircleAvatarAsyncState createState() => _CircleAvatarAsyncState();
}

class _CircleAvatarAsyncState extends State<CircleAvatarAsync> {
  List<int> imagem;
  User usuario;

  _CircleAvatarAsyncState();

  @override
  void initState(){
    super.initState();
    if(imagem == null && widget.idUsuario != null){
      if(widget.idUsuario == MyApp.userId()){
        imagem = MyApp.imageMemory;
      } else {
        FirebaseStorage.instance.ref()
            .child("perfil/" + widget.idUsuario + ".jpg")
            .getData(36000).then(chegouFotoPerfil)
            .catchError((e){});
        if(widget.clicavel != null) {
          Firestore.instance.collection(User.collectionName).document(
              widget.idUsuario).get().then(chegouUsuario)
              .catchError((e){});
        }
      }
    }
  }

  chegouFotoPerfil(List<int> img){
    setState(() {
      imagem = img;
    });
  }

  chegouUsuario(DocumentSnapshot doc){
    if(doc.data['tipo'] == UserType.institution.index){
      usuario = Institution.fromMap(doc.data, reference: doc.reference);
    } else {
      usuario = User.fromMap(doc.data, reference: doc.reference);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(widget.idUsuario + "circleavatarasync"),
      child: CircleAvatar(
        backgroundImage: imagem == null ?
            AssetImage("images/perfil_placeholder.png")
            : MemoryImage(imagem),
        radius: widget.radius,
      ),
      onTap: (){
        if(usuario != null && this.widget.clicavel){
          if(usuario.type == UserType.institution){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileInstitution(usuario))
            );
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePerson(usuario))
            );
          }
        }
      },
    );
  }

}