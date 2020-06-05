import 'package:benkyou/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Localization.dart';

class ThemeTransitionDialog extends StatelessWidget{
  final String name;
  final Color color;

  const ThemeTransitionDialog({Key key, @required this.name, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: AlertDialog(
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.green,
          child: Center(child:
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              name.toUpperCase(), textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
            ),
          )
          ),
        ),
      ),
    );
  }

}