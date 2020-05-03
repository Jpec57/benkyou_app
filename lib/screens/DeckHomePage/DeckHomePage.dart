import 'package:benkyou/models/UserCardReviewCount.dart';
import 'package:benkyou/screens/DeckHomePage/CreateDeckDialog.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/ConnectedActionDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/Deck.dart';
import '../../services/api/deckRequests.dart';
import '../../widgets/MainDrawer.dart';
import 'DeckContainer.dart';

class DeckHomePage extends StatefulWidget {
  static const routeName = '/home/deck';

  @override
  State<StatefulWidget> createState() => DeckHomePageState();
}

class DeckHomePageState extends State<DeckHomePage> {
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


  Widget _renderDeckWithReviewCount(Deck deck, int count){
    return Stack(
      children: <Widget>[
        _renderDeck(deck),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$count',
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
        ),
      ],
    );
  }

  Widget _renderDeckStack(Deck deck) {
    return FutureBuilder(
      future: personalDeckCounts,
      builder: (BuildContext context,
          AsyncSnapshot<List<UserCardReviewCount>> countSnapshot) {
        switch (countSnapshot.connectionState) {
          case ConnectionState.done:
            if (countSnapshot.hasData) {
              for (UserCardReviewCount userCardReviewCount in countSnapshot.data) {
                if (deck.id == userCardReviewCount.deckId) {
                  int count = userCardReviewCount.count;
                  if (count > 0) {
                    return _renderDeckWithReviewCount(deck, count);
                  }
                }
              }
            }
            return _renderDeck(deck);
          default:
            return _renderDeck(deck);
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
                            return _renderDeckStack(deck);
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
