import 'package:benkyou/models/DeckCard.dart';
import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/AddAnswerCardWidget.dart';
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
        title: Text('Modify card'),
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
                child: AddAnswerCardWidget(key: answerWidgetKey)),
            Expanded(
              flex: 1,
                child: Container(
                  color: Color(COLOR_DARK_BLUE),
                  child: Center(child: Text('Delete'.toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),)),
            Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: (){
                    print('Update');
                    print(answerWidgetKey.currentState.getAnswerStrings());
                  },
                  child: Container(
                    color: Color(COLOR_ORANGE),
                    child: Center(child: Text('Update'.toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)),),
                )),
          ],
        ),
      ),
    );
  }
}