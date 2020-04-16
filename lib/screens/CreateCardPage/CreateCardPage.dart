import 'package:benkyou_app/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateCardPage extends StatefulWidget {
  static const routeName = '/cards/new';
  final int deckId;

  const CreateCardPage({Key key, this.deckId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CreateCardPageState();
}

class CreateCardPageState extends State<CreateCardPage>{

  Widget _renderCreateCardContent(){
    return Text("Create card");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text("Create a card"),
      ),
      body: _renderCreateCardContent(),
    );
  }
}