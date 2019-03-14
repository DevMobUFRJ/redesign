import 'package:flutter/material.dart';
import 'package:redesign/estilos/style.dart';
import 'package:redesign/widgets/base_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {

  _launchURL(String url) async{
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Sobre",
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: ListView(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      child: Image.asset("images/labdis-logo.png", width: 100,),
                      onTap: () => _launchURL("http://lidis.ufrj.br"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: GestureDetector(
                        child: Image.asset("images/devmob-logo.png", width: 70,),
                        onTap: () => _launchURL("http://facebook.com/devmobufrj"),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 12.0,
                ),
                Text("App desenvolvido por DevMob UFRJ\n"
                    "George Rappel / Patrick Sasso\n"
                    "Design: LabDIS (Aline Netto)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
                Divider(color: Style.primaryColor, height: 28,),
                Text("REDEsign",
                  style: TextStyle(
                    fontSize: 20,
                    color: Style.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text("Rede Autônoma de Educação em Design",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text("O projeto da Rede Autônoma é responsável por criar uma interação entre os participantes, "
                      "os beneficiários e os interessados nos projetos Pegada nas Escolas e Design em Empreendimentos "
                      "Populares, assim como promover sua divulgação e permitir a continuidade dos mesmos. Essa pesquisa"
                      " tem apoio do CNPq.",
                    textAlign: TextAlign.justify,
                  ),
                ),
                Divider(color: Style.primaryColor, height: 28,),
                Text("Aplicativo",
                  style: TextStyle(
                    fontSize: 20,
                    color: Style.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text("O aplicativo foi desenvolvido através de uma parceria entre o LabDIS - "
                    "Laboratório de Design, Inovação e Sustentabilidade, e o DevMob UFRJ - Grupo de "
                    "Extensão focado no Desenvolvimento de Aplicativos. O app foi desenvolvido em "
                      "Flutter e seu código está aberto, disponível no Github do grupo.",
                    textAlign: TextAlign.justify,
                  ),
                ),
                Divider(color: Style.primaryColor, height: 28,),
              ]
            ),
          ),
        ],
      ),
    );
  }
}