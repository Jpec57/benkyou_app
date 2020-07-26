import 'dart:ui';

import 'package:flutter/material.dart';

class ExperienceBar extends StatelessWidget {
  final String skill;
  final Color emptyColor;
  final Color fullColor;
  final double percent;

  const ExperienceBar(
      {Key key,
      @required this.skill,
      @required this.percent,
      this.emptyColor = Colors.grey,
      this.fullColor = Colors.blue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              skill,
              textAlign: TextAlign.left,
            ),
          ),
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: emptyColor,
                height: 20,
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: percent,
                    child: Container(
                      color: fullColor,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
