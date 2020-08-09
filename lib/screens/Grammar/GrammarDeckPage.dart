import 'package:benkyou/models/Deck.dart';
import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/screens/Grammar/CreateGrammarCardArguments.dart';
import 'package:benkyou/screens/Grammar/CreateGrammarPage.dart';
import 'package:benkyou/screens/Grammar/GrammarHomePage.dart';
import 'package:benkyou/screens/Grammar/GrammarReviewArguments.dart';
import 'package:benkyou/screens/Grammar/GrammarReviewPage.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/services/api/deckRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:benkyou/widgets/ReviewSchedule.dart';
import 'package:benkyou/widgets/SRSPreview.dart';
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
  Future<List<UserCard>> _reviewCards;
  //TODO COUNT is better...
  Future<List<UserCard>> _deckCards;
  Future<List<UserCard>> _userCards;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    loadDeck();
  }

  void loadDeck() {
    _deck = getDeck(widget.deckId);
    _reviewCards = getReviewCardsForDeck(widget.deckId);
    _deckCards = getUserCardsForDeck(widget.deckId);
    _userCards = getUserCardsForDeck(widget.deckId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _createNewCard() {
    Navigator.pushNamed(context, CreateGrammarCardPage.routeName,
        arguments: CreateGrammarCardArguments(
          deckId: widget.deckId,
        ));
  }

  Widget _renderHeader(Deck deck) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(GrammarHomePage.routeName);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        FutureBuilder(
                          future: _deckCards,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<UserCard>> deckCardSnap) {
                            switch (deckCardSnap.connectionState) {
                              case ConnectionState.done:
                                if (deckCardSnap.hasData) {
                                  int count = deckCardSnap.data.length;
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${count ?? 0}",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  );
                                }
                                return Container();
                              default:
                                return Container();
                            }
                          },
                        ),
                        Icon(
                          Icons.inbox,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderReviewSchedule() {
    return FutureBuilder(
        future: _userCards,
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

  Widget _renderSRSPreview() {
    return FutureBuilder(
        future: _deckCards,
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

  Widget _renderPage(Deck deck) {
    return Expanded(
      child: Container(
        color: Color(COLOR_DARK_BLUE),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            _renderHeader(deck),
            Expanded(
              flex: 3,
              child: TopRoundedCard(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _refresh,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${deck.title}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline3
                                        .copyWith(color: Colors.black87),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${deck.description ?? ''}",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Color(COLOR_DARK_GREY)),
                                  ),
                                ),
                                _renderReviewSchedule(),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: _renderSRSPreview(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: FutureBuilder(
                        future: _reviewCards,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<UserCard>> reviewCardsSnap) {
                          switch (reviewCardsSnap.connectionState) {
                            case ConnectionState.done:
                              if (reviewCardsSnap.hasData) {
                                return RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                  color: Color(COLOR_ORANGE),
                                  onPressed: () {
                                    List<UserCard> reviewCards =
                                        reviewCardsSnap.data;
                                    if (reviewCards.length > 0) {
                                      Navigator.of(context).pushNamed(
                                          GrammarReviewPage.routeName,
                                          arguments: GrammarReviewArguments(
                                              deckId: widget.deckId,
                                              reviewCards: reviewCards));
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Text(
                                      "${reviewCardsSnap.data.length} Review"
                                          .toUpperCase(),
                                      style:
                                          Theme.of(context).textTheme.headline3,
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            default:
                              return Container();
                          }
                        },
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

  Future<void> _refresh() async {
    loadDeck();
    setState(() {});
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
                      child: Padding(
                        padding: const EdgeInsets.all(50),
                        child: CircularProgressIndicator(),
                      ),
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
        backgroundColor: Color(COLOR_ORANGE),
        tooltip: LocalizationWidget.of(context).getLocalizeValue('add_card'),
        child: Icon(Icons.add),
      ),
    );
  }
}
