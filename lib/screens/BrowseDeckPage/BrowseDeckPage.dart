import 'package:benkyou/models/Deck.dart';
import 'package:benkyou/screens/PreviewPublicDeckPage/PreviewPublicDeckPage.dart';
import 'package:benkyou/screens/PreviewPublicDeckPage/PreviewPublicDeckPageArguments.dart';
import 'package:benkyou/services/api/deckRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BrowseDeckPage extends StatefulWidget {
  static const routeName = '/browse/decks';

  @override
  State<StatefulWidget> createState() => BrowseDeckPageState();
}

class BrowseDeckPageState extends State<BrowseDeckPage> {
  Future<List<Deck>> decks;

  Widget _renderDeck(Deck deck) {
    return Padding(
      padding:
          const EdgeInsets.only(right: 12.0, left: 10, top: 10, bottom: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            PreviewPublicDeckPage.routeName,
            arguments: PreviewPublicDeckPageArguments(deck.id),
          );
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Color(COLOR_MID_DARK_GREY)),
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  deck.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "${deck.author.username}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    decks = getPublicDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationWidget.of(context).getLocalizeValue('browse_online_deck')),
      ),
      drawer: MainDrawer(),
      body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: FutureBuilder(
              future: decks,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Deck>> deckSnapshot) {
                switch (deckSnapshot.connectionState) {
                  case ConnectionState.none:
                    return Center(
                        child: Text(LocalizationWidget.of(context).getLocalizeValue('no_deck_create')));
                  case ConnectionState.done:
                    if (deckSnapshot.hasData) {
                      if (deckSnapshot.data.length == 0) {
                        return Center(
                            child:
                                Text(LocalizationWidget.of(context).getLocalizeValue('no_deck_create')));
                      }
                      return GridView.count(
                          crossAxisCount: 2,
                          key: ValueKey('deck-grid'),
                          children:
                              List.generate(deckSnapshot.data.length, (index) {
                            Deck deck = deckSnapshot.data[index];
                            return _renderDeck(deck);
                          }));
                    }
                    return Center(
                        child: Text(LocalizationWidget.of(context).getLocalizeValue('no_deck_create')));
                  default:
                    return Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('loading')));
                }
              })),
    );
  }
}
