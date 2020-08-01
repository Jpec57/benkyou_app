import 'package:benkyou/widgets/InfoDialog.dart';
import 'package:flutter/material.dart';

class InfoIcon extends StatelessWidget {
  final String info;
  final String title;

  const InfoIcon({Key key, @required this.info, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => InfoDialog(
                    title: this.title,
                    body: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          this.info,
                          textAlign: TextAlign.justify,
                          style: TextStyle(),
                        ),
                      ],
                    ),
                  ));
        },
        child: Icon(
          Icons.help_outline,
          size: 18,
        ));
  }
}
