import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GrammarReviewPage extends StatefulWidget{
  static const routeName = '/grammar/review';

  @override
  State<StatefulWidget> createState() => GrammarReviewPageState();

}

class GrammarReviewPageState extends State<GrammarReviewPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grammar review'),
      ),
      drawer: MainDrawer(),
      body: Container(),
    );
  }
}