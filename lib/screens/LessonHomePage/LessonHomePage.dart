import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LessonHomePage extends StatefulWidget{
  static const routeName = '/lessons';

  @override
  State<StatefulWidget> createState() => LessonHomePageState();

}

class LessonHomePageState extends State<LessonHomePage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationWidget.of(context).getLocalizeValue('lessons')),
      ),
      drawer: MainDrawer(),
      body: Container(),
    );
  }
}