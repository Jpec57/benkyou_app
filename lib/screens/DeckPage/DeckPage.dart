import 'package:benkyou_app/models/UserCard.dart';
import 'package:benkyou_app/screens/CreateCardPage/CreateCardPage.dart';
import 'package:benkyou_app/screens/CreateCardPage/CreateCardPageArguments.dart';
import 'package:benkyou_app/screens/ReviewPage/ReviewPage.dart';
import 'package:benkyou_app/screens/ReviewPage/ReviewPageArguments.dart';
import 'package:benkyou_app/services/api/cardRequests.dart';
import 'package:benkyou_app/utils/colors.dart';
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
  Future<List<UserCard>> userCards;
  Future<List<UserCard>> reviewCards;
  Future<Deck> deck;

  @override
  void initState() {
    super.initState();
    deck = getDeck(widget.id);
    userCards = getUserCardsForDeck(widget.id);
    reviewCards = getReviewCardsForDeck(widget.id);
  }

  void _createNewCard() {
    Navigator.pushNamed(context, CreateCardPage.routeName,
        arguments: CreateCardPageArguments(widget.id));
  }

  Widget _renderDeckPageContent(Deck deck) {
    if (deck != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: userCards,
          builder: (BuildContext context,
              AsyncSnapshot<List<UserCard>> userCardSnapshot) {
            switch (userCardSnapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: Text("Loading..."));
              case ConnectionState.done:
                if (userCardSnapshot.hasData) {
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
                          future: reviewCards,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<UserCard>>
                                  cardsToReviewSnapshot) {
                            switch (cardsToReviewSnapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Text("Loading...");
                              case ConnectionState.done:
                                if (cardsToReviewSnapshot.hasData) {
                                  List<UserCard> cardsToReview =
                                      cardsToReviewSnapshot.data;
                                  return RaisedButton(
                                    child:
                                        Text("${cardsToReview.length} Reviews"),
                                    onPressed: () {
                                      if (cardsToReview.length > 0){
                                        Navigator.pushNamed(
                                            context, ReviewPage.routeName,
                                            arguments: ReviewPageArguments(
                                                cardsToReview));
                                      }
                                    },
                                  );
                                }
                                return RaisedButton(
                                  child: Text("0 Review"),
                                  onPressed: () {},
                                );
                              default:
                                return Text("0 Review");
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }
                return Center(child: Text("The deck is empty. Please create a card."));
              default:
                return Center(child: Text("Loading..."));
            }
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
      future: deck,
      builder: (BuildContext context, AsyncSnapshot<Deck> deckSnapshot) {
        switch (deckSnapshot.connectionState) {
          case ConnectionState.waiting:
            return Scaffold(
                drawer: MainDrawer(),
                appBar: AppBar(
                  title: Text(""),
                ),
                body: Center(child: Text("Loading...")));
          case ConnectionState.done:
            Deck deckData;
            if (deckSnapshot.hasData) {
              deckData = deckSnapshot.data;
            }
            return Scaffold(
              drawer: MainDrawer(),
              appBar: AppBar(
                title: Text("Deck: ${deckData != null ? deckData.title : ''}"),
              ),
              body: _renderDeckPageContent(deckData),
              floatingActionButton: FloatingActionButton(
                onPressed: _createNewCard,
                backgroundColor: Color(COLOR_ORANGE),
                tooltip: 'Add a deck',
                child: Icon(Icons.add),
              ),
            );
          default:
            return Scaffold(
                appBar: AppBar(
                  title: Text(""),
                ),
                drawer: MainDrawer(),
                body: Center(child: Text("There is no deck with id ${widget.id}"))
            );
        }
      },
    );
  }
}
