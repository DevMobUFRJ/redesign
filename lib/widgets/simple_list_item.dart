import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redesign/styles/style.dart';

class SimpleListItem extends StatelessWidget {
  final String title;
  final double titleFontSize;
  final String subtitle;
  final VoidCallback callback;
  final Widget iconExtra;
  final Color textColor;
  final VoidCallback onLongPress;

  SimpleListItem(this.title, this.callback,
      {Key key,
      this.iconExtra,
      this.textColor = Style.primaryColor,
      this.subtitle,
      this.titleFontSize,
      this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: titleFontSize ?? 22.0,
              ),
            ),
            onTap: callback,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                iconExtra,
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.0,
                  color: Colors.black26,
                ),
              ].where((w) => w != null).toList(),
            ),
            subtitle: subtitle != null && subtitle.isNotEmpty
                ? Text(this.subtitle)
                : null,
            contentPadding: EdgeInsets.only(top: 2, bottom: 2),
            onLongPress: onLongPress,
          ),
          Divider(
            color: Colors.black38,
            height: 10,
          ),
        ],
      ),
    );
  }
}
