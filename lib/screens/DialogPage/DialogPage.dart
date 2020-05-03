import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogPage extends StatefulWidget{
  static const routeName = '/dialog';
  @override
  State<StatefulWidget> createState() => DialogPageState();

}

class DialogPageState extends State<DialogPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Dialog'),
      ),
      body: Container(),
    );
  }

}