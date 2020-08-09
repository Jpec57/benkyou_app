import 'package:benkyou/models/Deck.dart';
import 'package:benkyou/models/UserCardReviewCount.dart';
import 'package:benkyou/screens/DeckHomePage/CreateDeckDialog.dart';
import 'package:benkyou/screens/Grammar/GrammarDeckPage.dart';
import 'package:benkyou/screens/Grammar/GrammarDeckPageArguments.dart';
import 'package:benkyou/screens/Grammar/GrammarHomeHeaderClipper.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/services/api/deckRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/ConfirmDialog.dart';
import 'package:benkyou/widgets/ConnectedActionDialog.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:benkyou/widgets/RoundedTextField.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GrammarHomePage extends StatefulWidget {
  static const String routeName = '/grammar/home';

  @override
  _GrammarHomePageState createState() => _GrammarHomePageState();
}

class _GrammarHomePageState extends State<GrammarHomePage> {
  Future<List<Deck>> _grammarDecks;
  Future<List<UserCardReviewCount>> personalDeckCounts;
  Future<List<UserCardReviewCount>> _awaitingCardCounts;

  @override
  void initState() {
    super.initState();
    reloadDecks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void reloadDecks() {
    setState(() {
      _grammarDecks = getGrammarDecks();
      _awaitingCardCounts = getAwaitingCardCountsForAllDecks();
      personalDeckCounts = getReviewCardCountsForAllDecks();
    });
  }

  Widget _renderSearchBar() {
    return Container(
      child: RoundedTextField(),
    );
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
        builder: (BuildContext context) => CreateDeckDialog(
              callback: this.reloadDecks,
              isGrammar: true,
            ));
  }

  Widget returnDefaultTile(Deck deck) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(GrammarDeckPage.routeName,
            arguments: GrammarDeckPageArguments(deckId: deck.id));
      },
      title: Text(deck.title),
      subtitle: Text(
        deck.author != null ? deck.author.username : "Jpec",
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;

    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Grammar'),
        elevation: 0,
      ),
      body: SafeArea(
          child: Column(
        children: [
          GestureDetector(
            onTap: () {
              print("Cool");
              //TODO IMPLEMENT
            },
            child: ClipPath(
              clipper: GrammarHomeHeaderClipper(),
              child: Container(
                color: Color(COLOR_DARK_BLUE),
                height: phoneSize.height * 0.1,
                child: Align(
                  child: Text(
                    "All review",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  alignment: FractionalOffset(0.5, 0.2),
                ),
              ),
            ),
          ),
          _renderSearchBar(),
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 10, left: 10),
            child: FutureBuilder(
              future: _grammarDecks,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Deck>> deckSnapshot) {
                switch (deckSnapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.done:
                    if (deckSnapshot.hasData) {
                      return ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            Deck deck = deckSnapshot.data[index];
                            return Dismissible(
                              key: Key("${deck.id}"),
                              background: Container(color: Colors.red),
                              confirmDismiss: (direction) async {
                                bool shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        ConfirmDialog(
                                          action: LocalizationWidget.of(context)
                                              .getLocalizeValue(
                                                  'confirm_delete_deck_mess'),
                                          positiveCallback: () async {
                                            await deleteDeck(deck.id);
                                            Navigator.pushNamed(context,
                                                GrammarHomePage.routeName);
                                          },
                                        ));
                                return shouldDelete;
                              },
                              child: FutureBuilder(
                                  future: personalDeckCounts,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<UserCardReviewCount>>
                                          reviewCountSnap) {
                                    switch (reviewCountSnap.connectionState) {
                                      case ConnectionState.done:
                                        if (reviewCountSnap.hasData) {
                                          var data = reviewCountSnap.data;
                                          for (UserCardReviewCount userCardReviewCount
                                              in data) {
                                            if (deck.id ==
                                                userCardReviewCount.deckId) {
                                              int awaitingCount =
                                                  userCardReviewCount.count;
                                              if (awaitingCount > 0) {
                                                print(
                                                    "awaitingCount $awaitingCount");
                                                return ListTile(
                                                  onTap: () {
                                                    Navigator.of(context).pushNamed(
                                                        GrammarDeckPage
                                                            .routeName,
                                                        arguments:
                                                            GrammarDeckPageArguments(
                                                                deckId:
                                                                    deck.id));
                                                  },
                                                  title: Text(deck.title),
                                                  trailing: Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Text(
                                                        '$awaitingCount',
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
                                                );
                                              }
                                            }
                                          }
                                        }
                                        return returnDefaultTile(deck);
                                      default:
                                        return returnDefaultTile(deck);
                                    }
                                  }),
                            );
                          },
                          separatorBuilder: (context, index) => Divider(
                                color: Colors.black,
                              ),
                          itemCount: deckSnapshot.data.length);
                    }
                    return Center(
                        child: Text(LocalizationWidget.of(context)
                            .getLocalizeValue('empty')));
                  case ConnectionState.none:
                    return Center(
                        child: Text(LocalizationWidget.of(context)
                            .getLocalizeValue('no_internet_connection')));
                  default:
                    return Center(
                        child: Text(LocalizationWidget.of(context)
                            .getLocalizeValue('empty')));
                }
              },
            ),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewDeck,
        backgroundColor: Color(COLOR_ORANGE),
        tooltip: LocalizationWidget.of(context).getLocalizeValue('add_deck'),
        child: Icon(Icons.add),
      ),
    );
  }
}
