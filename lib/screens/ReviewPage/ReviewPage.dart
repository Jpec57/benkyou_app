import 'dart:math';

import 'package:benkyou_app/models/Answer.dart';
import 'package:benkyou_app/models/Deck.dart';
import 'package:benkyou_app/models/UserCard.dart';
import 'package:benkyou_app/models/UserCardProcessedInfo.dart';
import 'package:benkyou_app/screens/DeckPage/DeckPage.dart';
import 'package:benkyou_app/screens/DeckPage/DeckPageArguments.dart';
import 'package:benkyou_app/services/translator/TextConversion.dart';
import 'package:benkyou_app/utils/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget{
  static const routeName = '/review';

  final List<UserCard> cards;

  const ReviewPage({Key key, @required this.cards}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewPage>{
  bool isAnswerVisible = false;
  TextEditingController _answerController;
  List<UserCard> _remainingCards;
  List<UserCardProcessedInfo> _processedCards;
  int currentIndex;
  UserCard currentCard;

  @override
  void initState() {
    super.initState();
    _remainingCards = widget.cards;
    _processedCards = [];
    currentIndex = generateRandomIndex(_remainingCards);
    currentCard = _remainingCards[currentIndex];
    _answerController = new TextEditingController();
  }

  int generateRandomIndex(List list){
    Random random = new Random();
    return random.nextInt(list.length);
  }

  List<Widget> _renderAnswers(List<Answer> answers){
    List<Widget> answerWidgetList = [];
    for (Answer answer in answers){
      answerWidgetList.add(Text(answer.text));
    }
    return answerWidgetList;
  }


  Widget _renderAnswerPart(){
    if (!isAnswerVisible){
      return Container();
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
              "Possible answers"
          ),
          Divider(
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8, bottom: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _renderAnswers(currentCard.card.answers),
            ),
          ),

          Text(
              "User's note"
          ),
          Divider(
            thickness: 1,
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "Ici c'est les userNotes ${currentCard.userNote}"
              ),
            ),
          )
        ],
      ),
    );
  }

  bool _isUserAnswerValid(String userAnswer){
    List<String> parsedAnswers = getStringAnswers(currentCard.card.answers);
    for (String parsedAnswer in parsedAnswers){
      if (isStringDistanceValid(parsedAnswer, userAnswer)
          || getJapaneseTranslation(userAnswer) == parsedAnswer){
        return true;
      }
    }
    return false;
  }

  _moveToNextQuestion(){
    isAnswerVisible = false;
    int length = _remainingCards.length;
    if (_remainingCards.isNotEmpty){
      _remainingCards.removeAt(currentIndex);
    }
    if (length > 0){
      currentIndex = (length == 1) ? 0 : generateRandomIndex(_remainingCards);
      currentCard = _remainingCards[currentIndex];
    } else {
      Navigator.pushReplacementNamed(
          context,
          DeckPage.routeName,
          arguments: DeckPageArguments(currentCard.deck.id)
      );
    }
    setState(() {
      _answerController.clear();
    });
  }

  _processAnswer(){
    if (isAnswerVisible){
      _moveToNextQuestion();
      return;
    }
    String userAnswer = _answerController.text;
    bool isUserAnswerValid = _isUserAnswerValid(userAnswer);
    print("valid ? $isUserAnswerValid");
    _processedCards.add(new UserCardProcessedInfo(currentCard.id, isUserAnswerValid));
    if (isUserAnswerValid) {
      //TODO test on bunny mode instead of dummy second condition
      if (!isAnswerVisible && true){
        setState(() {
          isAnswerVisible = true;
        });
      } else{
        _moveToNextQuestion();
      }
    } else {
      if (!isAnswerVisible){
        setState(() {
          isAnswerVisible = true;
        });
      } else {
        _moveToNextQuestion();
      }

    }
  }


  @override
  Widget build(BuildContext context) {

    bool toEnglish = currentCard != null ? currentCard.card.answerLanguageCode == 0 : false;
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Text('Review'),
      ),
      body: GestureDetector(
        onTap: (){
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.blue,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(currentCard != null ? (currentCard.card.hint ?? '') : ''),
                              Text(currentCard != null ? currentCard.card.question : '',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),),
                            ],
                          )
                      ),)
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.black,
              height: 50,
              child: Center(
                child: Text(
                  toEnglish ? "ENGLISH" : "JAPANESE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _answerController,
                      decoration: InputDecoration(
                          hintText: toEnglish? 'Answer' : '答え',
                          labelStyle: TextStyle(
                          )
                      ),
                      textAlign: TextAlign.center,
                      autofocus: true,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      if (_answerController.text.isNotEmpty){
                        _processAnswer();
                      }
                    },
                    child: Container(
                      color: Colors.deepOrange,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  )
                ],
              ),
              color: Colors.white,
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                    child: _renderAnswerPart(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}