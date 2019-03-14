import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StandardButton extends StatelessWidget {

  final String title;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback callback;

  StandardButton(this.title, this.callback, this.backgroundColor, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: GestureDetector(
              child: Container(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(100.0)
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                        color: textColor, fontSize: 15
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ), onTap: callback,
            )
        ),
      ],
    );
  }
}
