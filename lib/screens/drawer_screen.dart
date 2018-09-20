import 'package:flutter/material.dart';

  class DrawerScreen extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        new DrawerHeader(
          child: new Container(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new RoundIconButton(
                  icon: Icons.favorite,
                  iconColor: Colors.white,
                  circleColor: new Color(0xffffffff),
                  size: 80.0,
                ),
                new Container(
                  width:160.0 ,
                  margin: new EdgeInsets.all(10.0),
                  child: new Column (
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text('Nome',
                        style: new TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal, fontSize: 25.0),
                      ),
                      new Text('Ocupação',
                        style: new TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal, fontSize: 17.0),
                      ),
                      new Container(
                        padding: new EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget> [
                            new RoundIconButton(
                              icon: Icons.favorite,
                              iconColor: Colors.white,
                              circleColor: new Color(0xff00838f),
                              size: 30.0,
                            ),
                            new RoundIconButton(
                              icon: Icons.favorite,
                              iconColor: Colors.white,
                              circleColor: new Color(0xff00838f),
                              size: 30.0,
                            ),
                            new RoundIconButton(
                              icon: Icons.favorite,
                              iconColor: Colors.white,
                              circleColor: new Color(0xff00838f),
                              size: 30.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          decoration: new BoxDecoration(
              color: Colors.black
          ),
        ),
        new ListaDrawer(
          icon: Icons.directions,
          iconColor: new Color(0xff00838f),
          text: 'Mapa',
        ),
        new ListaDrawer(
          icon: Icons.people,
          iconColor: new Color(0xff00838f),
          text: 'Rede',
        ),
        new ListaDrawer(
          icon: Icons.chat_bubble,
          iconColor: new Color(0xff00838f),
          text: 'Fórum',
        ),
        new ListaDrawer(
          icon: Icons.collections_bookmark,
          iconColor: new Color(0xff00838f),
          text: 'Materiais',
        ),
        new ListaDrawer(
          icon: Icons.calendar_today,
          iconColor: new Color(0xff00838f),
          text: 'Eventos',
        ),
      ],
    ),
    );
  }
  }
class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color circleColor;
  final double size;
  final VoidCallback onPressed;

  RoundIconButton({
    this.icon,
    this.iconColor,
    this.circleColor,
    this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: size,
      height: size,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        color: circleColor,
      ),
    );
  }
}

class ListaDrawer extends StatelessWidget{
  final IconData icon;
  final Color iconColor;
  final String text;

  ListaDrawer({
    this.icon,
    this.iconColor,
    this.text,
});

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: new Icon(icon,
          color: iconColor,),
      title: new Text(text,
        style: new TextStyle(
          color: Colors.black45),
      ),
    );
  }
}
