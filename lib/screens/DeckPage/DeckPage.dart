import 'package:benkyou_app/models/UserCard.dart';
import 'package:benkyou_app/screens/CreateCardPage/CreateCardPage.dart';
import 'package:benkyou_app/screens/CreateCardPage/CreateCardPageArguments.dart';
import 'package:benkyou_app/screens/ReviewPage/ReviewPage.dart';
import 'package:benkyou_app/screens/ReviewPage/ReviewPageArguments.dart';
import 'package:benkyou_app/services/api/cardRequests.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/Deck.dart';
import '../../services/api/deckRequests.dart';
import '../../widgets/MainDrawer.dart';

class DeckPage extends StatefulWidget {
  static const routeName = '/deck';
  final int id;

  const DeckPage({Key key, @required this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DeckPageState();

}

class DeckPageState extends State<DeckPage> {

  void _createNewCard(){
    Navigator.pushNamed(
        context,
        CreateCardPage.routeName,
        arguments: CreateCardPageArguments(widget.id)
    );
  }

  Widget _renderDeckPageContent(Deck deck){
    if (deck != null){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: getUserCardsForDeck(deck.id),
          builder: (BuildContext context, AsyncSnapshot<List<UserCard>> userCardSnapshot) {
            if (userCardSnapshot.hasData){
              List<UserCard> cards = userCardSnapshot.data;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Deck page ${deck.title} with ${cards.length} cards',
                    ),
                    FutureBuilder(
                      future: getReviewCardsForDeck(deck.id),
                      builder: (BuildContext context, AsyncSnapshot<List<UserCard>> cardsToReviewSnapshot) {
                        if (cardsToReviewSnapshot.hasData){
                          List<UserCard> cardsToReview = cardsToReviewSnapshot.data;
                          return RaisedButton(
                            child: Text("${cardsToReview.length} Reviews"),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context,
                                  ReviewPage.routeName,
                                arguments: ReviewPageArguments(cardsToReview)
                              );
                            },
                          );
                        }
                        return RaisedButton(
                          child: Text("Loading..."),
                          onPressed: () {
                          },
                        );
                    },
                    ),
                  ],
                ),
              );
            }
            return Center(child: Text("Loading..."));
        },
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
              title: Text("Deck: ${deck != null ? deck.title : ''}"),
            ),
            body: _renderDeckPageContent(deck),
            floatingActionButton: FloatingActionButton(
            onPressed: _createNewCard,
            backgroundColor: Colors.orange,
            tooltip: 'Add a deck',
            child: Icon(Icons.add),
          ),

        );
      },
    );
  }
}