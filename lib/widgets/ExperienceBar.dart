import 'dart:ui';

import 'package:benkyou/models/ExperienceLevelProgress.dart';
import 'package:flutter/material.dart';

class ExperienceBar extends StatelessWidget {
  final String skill;
  final Color emptyColor;
  final Color fullColor;
  final ExperienceLevelProgress progress;

  const ExperienceBar(
      {Key key,
      @required this.skill,
      @required this.progress,
      this.emptyColor = Colors.grey,
      this.fullColor = Colors.blue})
      : super(key: key);

  double formatProcess(ExperienceLevelProgress p) {
    return (p.maxXp - p.currentXp) / p.maxXp;
  }

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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    widthFactor: formatProcess(progress),
                    child: Container(
                      color: fullColor,
                    ),
                  ),
                ),
              )),
          Center(child: Text("${progress.currentXp} / ${progress.maxXp} xp")),
          Center(
              child: Text(
            "level ${progress.currentLevel} / ${progress.maxLevel}",
            style: TextStyle(fontWeight: FontWeight.w600),
          ))
        ],
      ),
    );
  }
}
