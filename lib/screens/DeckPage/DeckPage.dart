import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/Deck.dart';
import '../../services/api/deckRequests.dart';
import '../../widgets/MainDrawer.dart';
import '../HomePage/HomePage.dart';

class DeckPage extends StatefulWidget {
  static const routeName = '/deck';
  final int id;

  const DeckPage({Key key, @required this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DeckPageState();

}

class DeckPageState extends State<DeckPage> {

  Widget _renderDeckPageContent(Deck deck){
    if (deck != null){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Deck page ${deck.title}',
              ),
              RaisedButton(
                child: Text("Navigate to a home page"),
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    HomePage.routeName,
                  );
//                      Navigator.pushNamed(
//                        context,
//                        HomePage.routeName,
//                      );
                },
              ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: Text("There is no deck with id ${widget.id}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDeck(widget.id),
      builder: (BuildContext context, AsyncSnapshot<Deck> deckSnapshot) {
        Deck deck;
        if (deckSnapshot.hasData) {
          deck = deckSnapshot.data;
        }
        return Scaffold(
            drawer: MainDrawer(),
            appBar: AppBar(
              title: Text('lol'),
            ),
            body: _renderDeckPageContent(deck)

        );
      },
    );
  }
}