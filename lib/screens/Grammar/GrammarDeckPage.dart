import 'package:benkyou/models/Deck.dart';
import 'package:benkyou/screens/Grammar/CreateGrammarPage.dart';
import 'package:benkyou/services/api/deckRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:benkyou/widgets/TopRoundedCard.dart';
import 'package:flutter/material.dart';

class GrammarDeckPage extends StatefulWidget {
  static const routeName = '/grammar/deck';
  final int deckId;

  const GrammarDeckPage({Key key, @required this.deckId}) : super(key: key);

  @override
  _GrammarDeckPageState createState() => _GrammarDeckPageState();
}

class _GrammarDeckPageState extends State<GrammarDeckPage> {
  Future<Deck> _deck;

  @override
  void initState() {
    super.initState();
    loadDeck();
  }

  void loadDeck() {
    _deck = getDeck(widget.deckId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _createNewCard() {
    Navigator.pushNamed(context, CreateGrammarCardPage.routeName,
        arguments: CreateGrammarCardPage(
          deckId: widget.deckId,
        ));
  }

  Widget _renderPage(Deck deck) {
    return Expanded(
      child: Container(
        color: Colors.greenAccent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  child: Text("Coucou toi"),
                ),
              ),
            ),
//            Expanded(
//              child: TopRoundedCard(
//                child: Text("Test"),
//              ),
//            ),
            Expanded(
              flex: 3,
              child: TopRoundedCard(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Review".toUpperCase()),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        color: Color(COLOR_ORANGE),
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            "Review".toUpperCase(),
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            FutureBuilder(
              future: _deck,
              builder:
                  (BuildContext context, AsyncSnapshot<Deck> deckSnapshot) {
                switch (deckSnapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.done:
                    if (deckSnapshot.hasData) {
                      return _renderPage(deckSnapshot.data);
                    }
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            LocalizationWidget.of(context)
                                .getLocalizeValue('empty_deck_create_card'),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                                LocalizationWidget.of(context)
                                    .getLocalizeValue('card_explanation'),
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ));
                  case ConnectionState.none:
                    return Center(
                        child: Text(LocalizationWidget.of(context)
                            .getLocalizeValue('no_internet_connection')));
                  default:
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            LocalizationWidget.of(context)
                                .getLocalizeValue('empty_deck_create_card'),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                                LocalizationWidget.of(context)
                                    .getLocalizeValue('card_explanation'),
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ));
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewCard,
        backgroundColor: Color(COLOR_MID_DARK_GREY),
        tooltip: LocalizationWidget.of(context).getLocalizeValue('add_card'),
        child: Icon(Icons.add),
      ),
    );
  }
}
