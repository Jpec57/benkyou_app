import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InDialogListening extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => InDialogListeningState();

}

class InDialogListeningState extends State<InDialogListening>{

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