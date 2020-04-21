import 'package:benkyou_app/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BrowseDeckPage extends StatefulWidget{
  static const routeName= '/browse/decks';

  @override
  State<StatefulWidget> createState() => BrowseDeckPageState();
}

class BrowseDeckPageState extends State<BrowseDeckPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Online Deck'),
      ),
      drawer: MainDrawer(),
      body: Container(),
    );
  }

}