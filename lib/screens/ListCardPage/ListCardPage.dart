import 'package:benkyou/models/Answer.dart';
import 'package:benkyou/models/DeckCard.dart';
import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/screens/ModifyCardPage/ModifyCardPage.dart';
import 'package:benkyou/screens/ModifyCardPage/ModifyCardPageArguments.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/services/translator/TextConversion.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/utils/string.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListCardPage extends StatefulWidget {
  static const routeName = '/list/cards';
  final int deckId;

  const ListCardPage({Key key, this.deckId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ListCardPageState();
}

class ListCardPageState extends State<ListCardPage> {
  Future<List<UserCard>> cards;
  List<UserCard> filteredCards;
  TextEditingController _textEditingController;
  bool _isSearching = false;

  Future<List<UserCard>> _fetchUserCards() {
    if (widget.deckId != null) {
      return getUserJapaneseCardsForDeck(widget.deckId);
    }
    return getJapaneseUserCardsGroupByDeck();
  }

  @override
  void initState() {
    super.initState();
    cards = _fetchUserCards();
    _textEditingController = new TextEditingController();
    _textEditingController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  Widget _renderCardAnswers(UserCard userCard) {
    List<Answer> answers = List.of(userCard.card.answers)
      ..addAll(userCard.userAnswers);
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, ModifyCardPage.routeName,
            arguments: ModifyCardPageArguments(userCard));
      },
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: answers.length,
        itemBuilder: (BuildContext context, int index) {
          Answer answer = answers[index];
          return ListTile(
              title: Center(
                  child: Text(
            "${answer.text}",
            style: TextStyle(fontSize: 14),
          )));
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: Colors.grey,
          );
        },
      ),
    );
  }

  Widget _renderCardSubtitle(DeckCard deckCard) {
    if (deckCard.hint == null) {
      return null;
    }
    return Text("${deckCard.hint}",
        style: TextStyle(fontSize: 12, color: Colors.grey));
  }

  bool _doesCardContainsString(UserCard card, String searchTerm) {
    DeckCard deckCard = card.card;
    List<Answer> answers = List.of(deckCard.answers)..addAll(card.userAnswers);
    List<String> cardStrings = [
      deckCard.question,
      deckCard.hint,
    ];
    if (deckCard.languageCode == LANGUAGE_CODE_JAPANESE) {
      String possibleKanaString =
          deckCard.hint == null ? deckCard.question : deckCard.hint;
      cardStrings.add(getRomConversion(possibleKanaString));
    }

    for (Answer answer in answers) {
      if (deckCard.answerLanguageCode == LANGUAGE_CODE_JAPANESE) {
        cardStrings.add(getRomConversion(answer.text));
      }
      cardStrings.add(answer.text);
    }

    for (String cardString in cardStrings) {
      if (cardString != null && cardString.isNotEmpty) {
        if (getTrimmedLowerString(cardString).contains(searchTerm)) {
          return true;
        }
      }
    }
    return false;
  }

  List<UserCard> _filterCards(List<UserCard> cards, String searchText) {
    List<UserCard> filteredCards = [];
    for (UserCard card in cards) {
      if (_doesCardContainsString(card, searchText)) {
        filteredCards.add(card);
      }
    }
    return filteredCards;
  }

  Widget _renderCardList(List<UserCard> cards, String textFilter) {
    if (cards == null) {}
    if (textFilter != null && textFilter.isNotEmpty) {
      filteredCards = _filterCards(cards, textFilter);
    } else {
      filteredCards = cards;
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filteredCards.length,
      itemBuilder: (BuildContext context, int index) {
        DeckCard card = filteredCards[index].card;
        return ExpansionTile(
          backgroundColor: Color(COLOR_GREY),
          children: <Widget>[
            _renderCardAnswers(filteredCards[index]),
          ],
          title: Text("${card.question}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          subtitle: _renderCardSubtitle(card),
        );
      },
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey,
      ),
    );
  }

  Widget _renderResearchBar() {
    if (_isSearching) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _textEditingController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.white60),
              hintText: LocalizationWidget.of(context)
                  .getLocalizeValue('enter_search_word'),
              border: new UnderlineInputBorder(
                  borderSide: new BorderSide(color: Colors.white))),
        ),
      );
    }
    return Text(LocalizationWidget.of(context).getLocalizeValue('my_cards'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        bottomOpacity: 0.0,
//        elevation: 0.0,
        title: _renderResearchBar(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              if (_isSearching) {
                _textEditingController.clear();
              }
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
          future: cards,
          builder: (BuildContext context,
              AsyncSnapshot<List<UserCard>> cardSnapshot) {
            switch (cardSnapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                    child: Text(LocalizationWidget.of(context)
                        .getLocalizeValue('loading')));
              case ConnectionState.done:
                if (cardSnapshot.hasData && cardSnapshot.data.isNotEmpty) {
                  return Column(
                    children: <Widget>[
                      //TODO add filters ?

//                      Container(
//                        decoration: BoxDecoration(
//                            color: Color(COLOR_DARK_BLUE),
//                          boxShadow: [
//                            BoxShadow(
//                              color: Colors.black,
//                              blurRadius: 1.0,
//                              spreadRadius: 0.0,
//                              offset: Offset(2.0, 2.0), // shadow direction: bottom right
//                            )
//                          ],
//                        ),
//                        child: ExpansionTile(
//                          title: Center(
//                              child: Text('More filters', style: TextStyle(color: Colors.white),)
//                          ),
//                          children: <Widget>[
//                            Container(
//                              child: Text('Bonjour toi'),
//                            )
//                          ],
//
//                        ),
//                      ),
                      Expanded(
                          child: _renderCardList(
                              cardSnapshot.data, _textEditingController.text)),
                    ],
                  );
                }
                return Center(
                  child: Text(LocalizationWidget.of(context)
                      .getLocalizeValue('no_card_create_one')),
                );
              default:
                return Center(
                  child: Text(LocalizationWidget.of(context)
                      .getLocalizeValue('no_card_create_one')),
                );
            }
          }),
    );
  }
}
