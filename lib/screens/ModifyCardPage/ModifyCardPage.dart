import 'package:benkyou/models/DeckCard.dart';
import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/screens/ListCardPage/ListCardPage.dart';
import 'package:benkyou/screens/ListCardPage/ListCardPageArguments.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/AddAnswerCardWidget.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModifyCardPage extends StatefulWidget{
  static final String routeName = '/cards/modify';
  final UserCard userCard;

  const ModifyCardPage({Key key, this.userCard}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ModifyCardPageState();

}

class ModifyCardPageState extends State<ModifyCardPage>{
  GlobalKey<AddAnswerCardWidgetState> answerWidgetKey =
  new GlobalKey<AddAnswerCardWidgetState>();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      answerWidgetKey.currentState.setNewAnswers(widget.userCard.getAllAnswersAsString());
    });
  }

  @override
  Widget build(BuildContext context) {
    DeckCard deckCard = widget.userCard.card;
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationWidget.of(context).getLocalizeValue('modify_card')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
           Expanded(
             flex: 2,
             child: Padding(
               padding: const EdgeInsets.only(bottom: 15.0),
               child: Center(child: Text(deckCard.question, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
             ),
           ),
            Expanded(
              flex: 8,
              child: SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: AddAnswerCardWidget(key: answerWidgetKey, isScrollable: false,)),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  int deckId = widget.userCard.deck.id;
                  await deleteUserCard(widget.userCard.id);
                  Navigator.pushReplacementNamed(context, ListCardPage.routeName, arguments: ListCardPageArguments(deckId: deckId));
                },
                child: Container(
                  color: Color(COLOR_DARK_BLUE),
                  child: Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('delete').toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async{
                  int deckId = widget.userCard.deck.id;
                  await updateCardAnswers(widget.userCard.id, answerWidgetKey.currentState.getAnswerStrings());
                  Navigator.pushNamed(context, ListCardPage.routeName, arguments: ListCardPageArguments(deckId: deckId));

                },
                child: Container(
                  color: Color(COLOR_ORANGE),
                  child: Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('update').toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}