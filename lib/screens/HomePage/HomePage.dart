import 'package:benkyou_app/models/UserCardReviewCount.dart';
import 'package:benkyou_app/screens/HomePage/CreateDeckDialog.dart';
import 'package:benkyou_app/services/api/cardRequests.dart';
import 'package:benkyou_app/utils/colors.dart';
import 'package:benkyou_app/widgets/ConnectedActionDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/Deck.dart';
import '../../services/api/deckRequests.dart';
import '../../widgets/MainDrawer.dart';
import 'DeckContainer.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Future<List<Deck>> personalDecks;
  Future<List<UserCardReviewCount>> personalDeckCounts;

  @override
  void initState() {
    super.initState();
    personalDecks = getPersonalDecks();
    personalDeckCounts = getReviewCardCountsForAllDecks();
  }

  void _createNewDeck() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.get('userId') == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) => ConnectedActionDialog(
                action: "to create a deck.",
              ));
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            CreateDeckDialog(callback: this.reloadDecks));
  }

  void reloadDecks() {
    setState(() {
      personalDecks = getPersonalDecks();
      personalDeckCounts = getReviewCardCountsForAllDecks();
    });
  }

  Widget _renderDeck(Deck deck) {
    return Padding(
      padding:
          const EdgeInsets.only(right: 12.0, left: 10, top: 10, bottom: 10),
      child: DeckContainer(
        deck: deck,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Benkyou'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: FutureBuilder(
              future: personalDecks,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Deck>> deckSnapshot) {
                switch (deckSnapshot.connectionState) {
                  case ConnectionState.none:
                    return Center(
                        child: Text('No deck available. Please create one.'));
                  case ConnectionState.done:
                    if (deckSnapshot.hasData) {
                      if (deckSnapshot.data.length == 0) {
                        return Center(
                            child:
                                Text('No deck available. Please create one.'));
                      }
                      return GridView.count(
                          crossAxisCount: 2,
                          key: ValueKey('deck-grid'),
                          children:
                              List.generate(deckSnapshot.data.length, (index) {
                            Deck deck = deckSnapshot.data[index];
                            return FutureBuilder(
                              future: personalDeckCounts,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<UserCardReviewCount>>
                                      countSnapshot) {
                                switch (countSnapshot.connectionState) {
                                  case ConnectionState.done:
                                    if (countSnapshot.hasData) {
                                      for (UserCardReviewCount userCardReviewCount
                                          in countSnapshot.data) {
                                        if (deck.id ==
                                            userCardReviewCount.deckId) {
                                          int count = userCardReviewCount.count;
                                          if (count > 0) {
                                            return Stack(
                                              children: <Widget>[
                                                _renderDeck(deck),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        '$count',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                          Color(COLOR_ORANGE),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        }
                                        break;
                                      }
                                    }
                                    return _renderDeck(deck);
                                  default:
                                    return _renderDeck(deck);
                                }
                              },
                            );
                          }));
                    }
                    return Center(
                        child: Text('No deck available. Please create one.'));
                  default:
                    return Center(child: Text('Loading...'));
                }
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewDeck,
        backgroundColor: Color(COLOR_ORANGE),
        tooltip: 'Add a deck',
        child: Icon(Icons.add),
      ),
    );
  }
}
