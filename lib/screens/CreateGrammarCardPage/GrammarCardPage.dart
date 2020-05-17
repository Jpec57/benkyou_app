import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GrammarCardPage extends StatefulWidget{
  static const routeName = '/grammar/create';

  @override
  State<StatefulWidget> createState() => GrammarCardPageState();

}

class GrammarCardPageState extends State<GrammarCardPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create grammar card'),
      ),
      drawer: MainDrawer(),
      body: Container(),
    );
  }
}