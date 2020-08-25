import 'dart:io';

import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/models/UserCardReviewCount.dart';
import 'package:benkyou/screens/CreateCardPage/CreateCardPage.dart';
import 'package:benkyou/screens/CreateCardPage/CreateCardPageArguments.dart';
import 'package:benkyou/screens/DeckHomePage/CreateDeckDialog.dart';
import 'package:benkyou/screens/LoginPage/LoginPage.dart';
import 'package:benkyou/screens/ReviewPage/ReviewPage.dart';
import 'package:benkyou/screens/ReviewPage/ReviewPageArguments.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/services/localStorage/localStorageService.dart';
import 'package:benkyou/services/rest.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/ConnectedActionDialog.dart';
import 'package:benkyou/widgets/InfoDialog.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/Deck.dart';
import '../../services/api/deckRequests.dart';
import '../../widgets/MainDrawer.dart';
import 'DeckContainer.dart';

class DeckHomePage extends StatefulWidget {
  static const routeName = '/vocab/home';

  @override
  State<StatefulWidget> createState() => DeckHomePageState();
}

class DeckHomePageState extends State<DeckHomePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  Future<List<Deck>> personalDecks;
  Future<List<UserCardReviewCount>> personalDeckCounts;
  Future<List<UserCardReviewCount>> _awaitingCardCounts;
  Future<List<UserCard>> _allReviewCards;
  Future<int> _totalCount;

  Future<List<Deck>> _fetchPersonalDecks() async {
    List<Deck> parsedDecks = [];
    HttpClientResponse response =
        await getLocaleGetRequestResponse("/users/decks");
    if (!isRequestValid(response.statusCode)) {
      var jsonResponse = await getJsonFromHttpResponse(response);
      if (response.statusCode == 401) {
        Navigator.of(context).pushNamed(LoginPage.routeName);
        return null;
      }
      return null;
    }

    List<dynamic> decks = await getJsonFromHttpResponse(response);
    for (Map<String, dynamic> deck in decks) {
      parsedDecks.add(Deck.fromJson(deck));
    }
    return parsedDecks;
  }

  @override
  void initState() {
    super.initState();
    reloadDecks();
  }

  void _createNewDeck() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.get('userId') == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) => ConnectedActionDialog(
                action: LocalizationWidget.of(context)
                    .getLocalizeValue('action_to_create_deck'),
              ));
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) => CreateDeckDialog());
  }

  void reloadDecks() {
    setState(() {
      personalDecks = getPersonalDecks();
      personalDeckCounts = getReviewCardCountsForAllDecks();
      _allReviewCards = getReviewCards();
      _totalCount = getUserCardsCount();
      _awaitingCardCounts = getAwaitingCardCountsForAllDecks();
    });
  }

  Widget _renderDeckAwaitingCount(Deck deck) {
    return FutureBuilder(
      future: _awaitingCardCounts,
      builder:
          (BuildContext context, AsyncSnapshot<dynamic> awaitingCountSnap) {
        switch (awaitingCountSnap.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.done:
            if (awaitingCountSnap.hasData) {
              var data = awaitingCountSnap.data;
              for (UserCardReviewCount userCardReviewCount in data) {
                if (deck.id == userCardReviewCount.deckId) {
                  int awaitingCount = userCardReviewCount.count;
                  if (awaitingCount > 0) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            '$awaitingCount',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(COLOR_DARK_MUSTARD),
                        ),
                      ),
                    );
                  }
                }
              }
              return Container();
            }
            return Container();
          case ConnectionState.none:
            return Container();
          default:
            return Container();
        }
      },
    );
  }

  Widget _renderDeckReviewCount(Deck deck) {
    return FutureBuilder(
      future: personalDeckCounts,
      builder: (BuildContext context,
          AsyncSnapshot<List<UserCardReviewCount>> reviewCountSnap) {
        switch (reviewCountSnap.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.done:
            if (reviewCountSnap.hasData) {
              var data = reviewCountSnap.data;
              for (UserCardReviewCount userCardReviewCount in data) {
                if (deck.id == userCardReviewCount.deckId) {
                  int reviewCount = userCardReviewCount.count;
                  if (reviewCount > 0) {
                    return Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            '$reviewCount',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(COLOR_ORANGE),
                        ),
                      ),
                    );
                  }
                }
              }
              return Container();
            }
            return Container();
          case ConnectionState.none:
            return Container();
          default:
            return Container();
        }
      },
    );
  }

  Widget _renderDeckStack(Deck deck) {
    return Stack(
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(right: 12.0, left: 10, top: 10, bottom: 10),
          child: DeckContainer(
            deck: deck,
          ),
        ),
        _renderDeckAwaitingCount(deck),
        _renderDeckReviewCount(deck),
      ],
    );
  }

  Widget _renderAllDecksReviewWidget() {
    return FutureBuilder(
      future: _allReviewCards,
      builder: (BuildContext context,
          AsyncSnapshot<List<UserCard>> allCardsSnapshot) {
        switch (allCardsSnapshot.connectionState) {
          case ConnectionState.done:
            if (allCardsSnapshot.data == null ||
                allCardsSnapshot.data.length == 0) {
              return Container();
            }
            List<UserCard> cards = allCardsSnapshot.data;
            int length = cards.length;
            return Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, ReviewPage.routeName,
                      arguments: ReviewPageArguments(cards: cards));
                },
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color(COLOR_ORANGE)),
                  child: Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          LocalizationWidget.of(context)
                              .getLocalizeValue('review_all_decks'),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(
                        '($length)',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
                ),
              ),
            );
          case ConnectionState.waiting:
            return Center(
              child: Text(
                  LocalizationWidget.of(context).getLocalizeValue('loading')),
            );
          default:
            return Center(
              child: Text(LocalizationWidget.of(context)
                  .getLocalizeValue('no_internet_connection')),
            );
        }
      },
    );
  }

  Future<void> _refresh() async {
    reloadDecks();
    setState(() {});
  }

  void _createNewCard(int deckId) {
    Navigator.pushNamed(context, CreateCardPage.routeName,
        arguments: CreateCardPageArguments(deckId));
  }

  Widget _renderFloatingButtons() {
    Widget defaultWidget = FloatingActionButton(
      onPressed: _createNewDeck,
      backgroundColor: Color(COLOR_ORANGE),
      tooltip: LocalizationWidget.of(context).getLocalizeValue('add_deck'),
      child: Icon(Icons.add),
    );
    return FutureBuilder(
      future: getLastUsedDeckIdFromLocalStorage(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasData) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () {
                      _createNewCard(snapshot.data);
                    },
                    backgroundColor: Color(0xffcceeff),
                    tooltip:
                        LocalizationWidget.of(context).getLocalizeValue('lol'),
                    child: Icon(
                      Icons.history,
                      color: Colors.black54,
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: _createNewDeck,
                    backgroundColor: Color(COLOR_ORANGE),
                    tooltip: LocalizationWidget.of(context)
                        .getLocalizeValue('add_deck'),
                    child: Icon(Icons.add),
                  ),
                ],
              );
            }
            return defaultWidget;

          default:
            return defaultWidget;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Benkyou'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => InfoDialog(
                        body: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              LocalizationWidget.of(context)
                                  .getLocalizeValue('deck_info_1'),
                              textAlign: TextAlign.justify,
                              style: TextStyle(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                LocalizationWidget.of(context)
                                    .getLocalizeValue('deck_info_2'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                LocalizationWidget.of(context)
                                    .getLocalizeValue('deck_info_3'),
                              ),
                            )
                          ],
                        ),
                      ));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _renderAllDecksReviewWidget(),
            Expanded(
              child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                  child: FutureBuilder(
                      future: personalDecks,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Deck>> deckSnapshot) {
                        switch (deckSnapshot.connectionState) {
                          case ConnectionState.none:
                            return Center(
                                child: Text(LocalizationWidget.of(context)
                                    .getLocalizeValue(
                                        'no_internet_connection')));
                          case ConnectionState.done:
                            if (deckSnapshot.hasData) {
                              if (deckSnapshot.data.length == 0) {
                                return Center(
                                    child: Text(LocalizationWidget.of(context)
                                        .getLocalizeValue('no_deck_create')));
                              }
                              return GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  key: ValueKey('deck-grid'),
                                  children: List.generate(
                                      deckSnapshot.data.length, (index) {
                                    Deck deck = deckSnapshot.data[index];
                                    return _renderDeckStack(deck);
                                  }));
                            }
                            return Center(
                                child: Text(LocalizationWidget.of(context)
                                    .getLocalizeValue('no_deck_create')));
                          default:
                            return Center(child: CircularProgressIndicator());
                        }
                      })),
            ),
            FutureBuilder(
              future: _totalCount,
              builder: (BuildContext context, AsyncSnapshot<int> countSnap) {
                switch (countSnap.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                      child: Text(LocalizationWidget.of(context)
                          .getLocalizeValue('loading')),
                    );
                  case ConnectionState.done:
                    if (countSnap.hasData) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: RichText(
                          text: TextSpan(
                            text: '',
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Total: ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '${countSnap.data} cards'),
                            ],
                          ),
                        ),
                      );
                    }
                    return Container();
                  default:
                    return Container();
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(left: 25),
        child: _renderFloatingButtons(),
      ),
    );
  }
}
