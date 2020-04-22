import 'package:benkyou_app/models/Answer.dart';
import 'package:benkyou_app/models/DeckCard.dart';
import 'package:benkyou_app/models/UserCard.dart';
import 'package:benkyou_app/services/api/cardRequests.dart';
import 'package:benkyou_app/utils/colors.dart';
import 'package:benkyou_app/widgets/MainDrawer.dart';
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

  Future<List<UserCard>> _fetchUserCards() {
    if (widget.deckId != null) {
      return getUserCardsForDeck(widget.deckId);
    }
    return getUserCardsGroupByDeck();
  }

  @override
  void initState() {
    super.initState();
    cards = _fetchUserCards();
  }

  Widget _renderCardAnswers(UserCard userCard) {
    List<Answer> answers = List.of(userCard.card.answers)..addAll(userCard.userAnswers);
    return ListView.separated(
        shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
        itemCount: answers.length,
        itemBuilder: (BuildContext context, int index) {
          Answer answer = answers[index];
          return ListTile(title: Center(child: Text("${answer.text}")));
        }, separatorBuilder: (BuildContext context, int index) {
      return Divider(
        color: Colors.grey,
      );
    },);
  }

  Widget _renderCardSubtitle(DeckCard deckCard){
    if (deckCard.hint == null){
      return null;
    }
    return Text("${deckCard.hint}", style: TextStyle(fontSize: 14, color: Colors.grey));
  }

  Widget _renderCardList(){
    return FutureBuilder(
      future: cards,
      builder: (BuildContext context,
          AsyncSnapshot<List<UserCard>> cardSnapshot) {
        switch (cardSnapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: Text('Loading...'));
          case ConnectionState.done:
            if (cardSnapshot.hasData) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: cardSnapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  DeckCard card = cardSnapshot.data[index].card;
                  return ExpansionTile(
                    children: <Widget>[
                      _renderCardAnswers(cardSnapshot.data[index]),
                    ],
                    title: Text("${card.question}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                    subtitle: _renderCardSubtitle(card),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey,
                ),
              );
            }
            return Center(child: Text('There is no card yet. Create one.'));
          default:
            return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My cards'),
      ),
      drawer: MainDrawer(),
      body: _renderCardList(),
    );
  }
}
