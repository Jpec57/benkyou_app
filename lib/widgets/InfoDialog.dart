import 'package:benkyou/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Localization.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final Widget body;

  const InfoDialog({Key key, @required this.body, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.all(10.0),
      title: Text(LocalizationWidget.of(context).getLocalizeValue('info')),
      content: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.height * 0.7,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                body,
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 5.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0))),
                    color: Color(COLOR_ORANGE),
                    child: Text(
                      LocalizationWidget.of(context)
                          .getLocalizeValue('close')
                          .toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
//                          widget.positiveCallback(_controller.text);
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
