import 'package:benkyou/utils/colors.dart';
import 'package:flutter/material.dart';

class NotificationWidget extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color textColor;
  final String text;

  const NotificationWidget(
      {Key key,
      this.size = 27,
      this.backgroundColor = const Color(COLOR_DARK_MUSTARD),
      this.textColor = Colors.white,
      @required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
            height: size + 3,
            width: size + 3,
            color: backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Center(
                  child: Text(
                text,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              )),
            )));
  }
}
