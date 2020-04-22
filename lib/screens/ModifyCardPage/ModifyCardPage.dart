import 'package:benkyou_app/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModifyCardPage extends StatefulWidget{
  final int cardId;

  const ModifyCardPage({Key key, this.cardId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ModifyCardPageState();

}

class ModifyCardPageState extends State<ModifyCardPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify card'),
      ),
      drawer: MainDrawer(),
      body: Container(
        child: Text('Ici'),
      ),
    );
  }
}