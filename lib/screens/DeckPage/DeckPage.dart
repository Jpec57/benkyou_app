import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/screens/CreateCardPage/CreateCardPage.dart';
import 'package:benkyou/screens/CreateCardPage/CreateCardPageArguments.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/screens/ReviewPage/ReviewPage.dart';
import 'package:benkyou/screens/ReviewPage/ReviewPageArguments.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/PublishDeckDialog.dart';
import 'package:benkyou/widgets/ReviewSchedule.dart';
import 'package:benkyou/widgets/SRSPreview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  Widget _renderReviewSchedule(){
    return FutureBuilder(
        future: userCards,
        builder: (BuildContext context,
            AsyncSnapshot<List<UserCard>> userCardSnapshot) {
          switch (userCardSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Container();
            case ConnectionState.done:
              if (userCardSnapshot.hasData) {
                List<UserCard> cards = userCardSnapshot.data;
                if (cards.isEmpty) {
                  return Container();
                }
                return ReviewSchedule(
                  cards: cards,
                  colors: [Color(COLOR_ORANGE)],
                );
              }
              return Container();
            default:
              return Container();
          }
        });
  }

  Widget _renderSRSPreview(){
    return FutureBuilder(
        future: userCards,
        builder: (BuildContext context,
            AsyncSnapshot<List<UserCard>> userCardSnapshot) {
          switch (userCardSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Container();
            case ConnectionState.done:
              if (userCardSnapshot.hasData) {
                List<UserCard> cards = userCardSnapshot.data;
                if (cards.isEmpty) {
                  return Container();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: SRSPreview(
                    cards: cards,
                  ),
                );
              }
              return Container();
            default:
              return Container();
          }
        });
  }

  Widget _renderDeckPageContent(Deck deck) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _renderReviewSchedule(),
        _renderSRSPreview(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
            future: userCards,
            builder: (BuildContext context,
                AsyncSnapshot<List<UserCard>> userCardSnapshot) {
              switch (userCardSnapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('loading')));
                case ConnectionState.done:
                  if (userCardSnapshot.hasData) {
                    List<UserCard> cards = userCardSnapshot.data;
                    print(cards);
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RichText(
                            textAlign: TextAlign.center,
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                new TextSpan(text: 'Deck ${deck.title} contains '),
                                new TextSpan(text: '${cards.length}', style: new TextStyle(fontWeight: FontWeight.bold)),
                                new TextSpan(text: ' cards.'),

                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: FutureBuilder(
                              future: reviewCards,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<UserCard>>
                                      cardsToReviewSnapshot) {
                                switch (cardsToReviewSnapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Text(LocalizationWidget.of(context).getLocalizeValue('loading'));
                                  case ConnectionState.done:
                                    if (cardsToReviewSnapshot.hasData) {
                                      List<UserCard> cardsToReview =
                                          cardsToReviewSnapshot.data;
                                      int length = cardsToReview.length;
                                      return ButtonTheme(
                                        minWidth: MediaQuery.of(context).size.width * 0.6,
                                        child: RaisedButton(
                                          color: Color(COLOR_DARK_BLUE),
                                          child: Text(
                                              "$length Review${length > 0 ? 's' : ''}",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () {
                                            if (length > 0) {
                                              Navigator.pushNamed(
                                                  context, ReviewPage.routeName,
                                                  arguments: ReviewPageArguments(
                                                      cards: cardsToReview, deckId: widget.id));
                                            } else {
                                              Scaffold.of(context).showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'There is nothing to review, you have to wait ;)')));
                                            }
                                          },
                                        ),
                                      );
                                    }
                                    return RaisedButton(
                                      color: Color(COLOR_DARK_BLUE),
                                      child: Text("0 Review",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {},
                                    );
                                  default:
                                    return RaisedButton(
                                      color: Color(COLOR_DARK_BLUE),
                                      child: Text("0 Review",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {},
                                    );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(LocalizationWidget.of(context).getLocalizeValue('empty_deck_create_card'), textAlign: TextAlign.center,),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Text(LocalizationWidget.of(context).getLocalizeValue('card_explanation'), textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                      ));
                default:
                  return Center(
                      child: Text(LocalizationWidget.of(context).getLocalizeValue('card_explanation')));
              }
            },
          ),
        ),
      ],
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
                body: Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('loading'))));
          case ConnectionState.done:
            Deck deckData;
            if (deckSnapshot.hasData && deckSnapshot.data != null) {
              deckData = deckSnapshot.data;
              return Scaffold(
                appBar: AppBar(
                  title:
                      Text("Deck: ${deckData != null ? deckData.title : ''}"),
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    onPressed: (){
                      Navigator.pushReplacementNamed(context, DeckHomePage.routeName);
                      },
                    icon: Icon(Icons.arrow_back),
                  ),
                  actions: <Widget>[
                    // action button
                    IconButton(
                      icon: Icon(Icons.public),
                      color: deckData.isPublic ? Color(COLOR_ORANGE) : Color(COLOR_GREY),
                      onPressed: () {
                        if (deckData.cards.length == 0){
                          Get.snackbar(LocalizationWidget.of(context).getLocalizeValue('empty_deck'), LocalizationWidget.of(context).getLocalizeValue('empty_deck_publish_error'), snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => PublishDeckDialog(
                              deck: deckData,
                            ));
                      },
                    ),
                  ],
                ),
                body: SingleChildScrollView(child: _renderDeckPageContent(deckData)),
                floatingActionButton: FloatingActionButton(
                  onPressed: _createNewCard,
                  backgroundColor: Color(COLOR_ORANGE),
                  tooltip: LocalizationWidget.of(context).getLocalizeValue('add_deck'),
                  child: Icon(Icons.add),
                ),
              );
            }
            return Scaffold(
                appBar: AppBar(
                  title: Text(""),
                ),
                body: Center(
                    child: Text("There is no deck with id ${widget.id}")));
          default:
            return Scaffold(
                appBar: AppBar(
                  title: Text(""),
                ),
                body: Center(
                    child: Text("There is no deck with id ${widget.id}")));
        }
      },
    );
  }
}
