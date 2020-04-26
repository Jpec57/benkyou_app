import 'package:benkyou/models/Answer.dart';
import 'package:benkyou/models/DeckCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeckCardList extends StatefulWidget{
  final List<DeckCard> cards;

  const DeckCardList({Key key, @required this.cards}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DeckCardListState();

}

class DeckCardListState extends State<DeckCardList>{

  Widget _renderCardAnswers(List<Answer> answers) {
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
    return Text("${deckCard.hint}", style: TextStyle(fontSize: 12, color: Colors.grey));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.length == 0){
      return Center(child: Text('There is no card yet.'));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.cards.length,
      itemBuilder: (BuildContext context, int index) {
        DeckCard card = widget.cards[index];
        return ExpansionTile(
          children: <Widget>[
            _renderCardAnswers(card.answers),
          ],
          title: Text("${card.question}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          subtitle: _renderCardSubtitle(card),
        );
      },
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey,
      ),
    );
  }
}