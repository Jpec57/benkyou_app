import 'package:benkyou/models/Deck.dart';
import 'package:benkyou/models/DeckCard.dart';
import 'package:benkyou/screens/BrowseDeckPage/BrowseDeckPage.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/screens/DeckPage/DeckPage.dart';
import 'package:benkyou/screens/DeckPage/DeckPageArguments.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/services/api/deckRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/DeckCardList.dart';
import 'package:benkyou/widgets/LoadingCircle.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreviewPublicDeckPage extends StatefulWidget {
  static const routeName = '/preview/deck';
  final int deckId;

  const PreviewPublicDeckPage({Key key, @required this.deckId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PreviewPublicDeckPageState();
}

class PreviewPublicDeckPageState extends State<PreviewPublicDeckPage> {
  Future<Deck> deckFuture;
  Future<List<DeckCard>> _cards;

  @override
  void initState() {
    super.initState();
    deckFuture = getDeck(widget.deckId);
    _cards = getDeckCards(widget.deckId);
  }

  Widget _renderDescription(Deck deck) {
    if (deck.description != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 18.0),
        child: Text(
          deck.description,
          style: TextStyle(
            fontSize: 17,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 3.0,
                color: Colors.grey,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            LocalizationWidget.of(context).getLocalizeValue('preview_deck')),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, BrowseDeckPage.routeName);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder(
        future: deckFuture,
        builder: (BuildContext context, AsyncSnapshot deckSnapshot) {
          switch (deckSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: Text(
                    LocalizationWidget.of(context).getLocalizeValue('loading')),
              );
            case ConnectionState.done:
              if (deckSnapshot.hasData) {
                Deck deck = deckSnapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.5),
                                    BlendMode.dstATop),
                                image: AssetImage("lib/imgs/japan.png"),
                                fit: BoxFit.cover)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  deck.title,
                                  style: TextStyle(shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 3.0,
                                      color: Colors.grey,
                                    ),
                                  ], fontSize: 26),
                                  textAlign: TextAlign.center,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    //TODO login
                                  },
                                  child: Text(
                                    LocalizationWidget.of(context)
                                            .getLocalizeValue('by') +
                                        " ${deck.author != null ? deck.author.username : "Jpec"}",
                                    style: TextStyle(
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 3.0,
                                            color: Colors.grey,
                                          ),
                                        ],
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                _renderDescription(deck)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              color: Color(COLOR_DARK_BLUE),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: Text(
                                  LocalizationWidget.of(context)
                                      .getLocalizeValue('list_cards_in_deck'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ),
                            ),
                            Expanded(
                                child: Container(
                                    color: Color(COLOR_DARK_BLUE),
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 12, right: 12),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(5.0),
                                                topRight: Radius.circular(5.0)),
                                            color: Colors.white,
                                          ),
                                          child: FutureBuilder(
                                            future: _cards,
                                            builder: (BuildContext context,
                                                AsyncSnapshot<List<DeckCard>>
                                                    cardSnap) {
                                              switch (
                                                  cardSnap.connectionState) {
                                                case ConnectionState.waiting:
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                case ConnectionState.done:
                                                  if (cardSnap.hasData) {
                                                    return DeckCardList(
                                                        cards: cardSnap.data);
                                                  }
                                                  return Container();
                                                case ConnectionState.none:
                                                  return Center(
                                                      child: Text(
                                                          LocalizationWidget.of(
                                                                  context)
                                                              .getLocalizeValue(
                                                                  'no_internet_connection')));
                                                default:
                                                  return Center(
                                                      child: Text(
                                                          LocalizationWidget.of(
                                                                  context)
                                                              .getLocalizeValue(
                                                                  'empty')));
                                              }
                                            },
                                          ),
                                        )))),
                          ],
                        )),
                    GestureDetector(
                      onTap: () async {
                        SharedPreferences shared =
                            await SharedPreferences.getInstance();
                        if (shared.get('apiToken') == null) {
                          Get.snackbar(
                              LocalizationWidget.of(context)
                                  .getLocalizeValue('error'),
                              LocalizationWidget.of(context).getLocalizeValue(
                                  'must_be_connected_message'),
                              snackPosition: SnackPosition.BOTTOM);
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            DeckHomePage.routeName,
                          );
                        } else {
                          if (deck.author == null ||
                              shared.get('username') != deck.author.username) {
                            showLoadingDialog(context);
                            Deck importedDeck = await importDeck(deck.id);
                            Navigator.pop(context);
                            Navigator.pushNamed(context, DeckPage.routeName,
                                arguments: DeckPageArguments(importedDeck.id));
                          } else {
                            Get.snackbar(
                                LocalizationWidget.of(context)
                                    .getLocalizeValue('error'),
                                LocalizationWidget.of(context)
                                    .getLocalizeValue('import_own_deck_error'),
                                snackPosition: SnackPosition.BOTTOM);
                          }
                        }
                      },
                      child: Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          color: Color(COLOR_ORANGE),
                          child: Center(
                              child: Text(
                            LocalizationWidget.of(context)
                                .getLocalizeValue('import_deck')
                                .toUpperCase(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ))),
                    ),
                  ],
                );
              }
              return Center(
                child: Text(
                    LocalizationWidget.of(context).getLocalizeValue('no_data')),
              );
            default:
              return Center(
                child: Text(
                    LocalizationWidget.of(context).getLocalizeValue('no_data')),
              );
          }
        },
      ),
    );
  }
}
