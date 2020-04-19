import 'dart:math';

import 'package:benkyou_app/models/Answer.dart';
import 'package:benkyou_app/models/UserCard.dart';
import 'package:benkyou_app/models/UserCardProcessedInfo.dart';
import 'package:benkyou_app/screens/DeckPage/DeckPage.dart';
import 'package:benkyou_app/screens/DeckPage/DeckPageArguments.dart';
import 'package:benkyou_app/screens/ReviewPage/ReviewPageInfo.dart';
import 'package:benkyou_app/services/api/cardRequests.dart';
import 'package:benkyou_app/services/translator/TextConversion.dart';
import 'package:benkyou_app/utils/colors.dart';
import 'package:benkyou_app/utils/string.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  static const routeName = '/review';

  final List<UserCard> cards;

  const ReviewPage({Key key, @required this.cards}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewPage> {
  bool isAnswerVisible = false;
  bool _isPlayingAnimation = false;
  final FlareControls _validAnswerAnimControls = FlareControls();

  TextEditingController _answerController;
  List<UserCard> _remainingCards;
  List<int> _processedCardIds;
  List<UserCardProcessedInfo> _processedCards;
  int currentIndex;
  int nbErrors = 0;
  int nbSuccess = 0;
  UserCard currentCard;

  @override
  void initState() {
    super.initState();
    _remainingCards = widget.cards;
    _processedCards = [];
    _processedCardIds = [];
    currentIndex = generateRandomIndex(_remainingCards);
    currentCard = _remainingCards[currentIndex];
    _answerController = new TextEditingController();
  }

  int generateRandomIndex(List list) {
    Random random = new Random();
    return random.nextInt(list.length);
  }

  List<Widget> _renderAnswers(List<Answer> answers) {
    List<Widget> answerWidgetList = [];
    for (Answer answer in answers) {
      answerWidgetList.add(Text(answer.text));
    }
    return answerWidgetList;
  }

  Widget _renderUserNotes(String userNote){
    if (userNote != null){
      return Text(currentCard.userNote);
    }
    return Text('Add a note');
  }

  Widget _renderAnswerPart() {
    if (!isAnswerVisible) {
      return Container();
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Possible answers"),
          Divider(
            thickness: 1,
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 8.0, left: 8, right: 8, bottom: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _renderAnswers(currentCard.card.answers),
            ),
          ),
          Text("User's note"),
          Divider(
            thickness: 1,
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _renderUserNotes(currentCard.userNote),
            ),
          )
        ],
      ),
    );
  }

  bool _isUserAnswerValid(String userAnswer) {
    List<String> parsedAnswers = getStringAnswers(currentCard.card.answers);
    for (String parsedAnswer in parsedAnswers) {
      if (isStringDistanceValid(parsedAnswer, userAnswer) ||
          getJapaneseTranslation(userAnswer) == parsedAnswer) {
        return true;
      }
    }
    return false;
  }

  _sendReview(List<UserCardProcessedInfo> reviewedCards) async {
//    await postReview(reviewedCards);
  }

  _moveToNextQuestion(bool isAnswerCorrect) async {
    isAnswerVisible = false;
    _isPlayingAnimation = false;
    int length = _remainingCards.length;
    if (length > 1) {
      //Remove only if correct
      if (isAnswerCorrect){
        _remainingCards.removeAt(currentIndex);
      }
      currentIndex = (length == 1) ? 0 : generateRandomIndex(_remainingCards);
      currentCard = _remainingCards[currentIndex];
    } else {
      await _sendReview(_processedCards);
      Navigator.pushReplacementNamed(context, DeckPage.routeName,
          arguments: DeckPageArguments(currentCard.deck.id));
    }
    setState(() {
      _answerController.clear();
    });
  }

  _processAnswer() {
    String userAnswer = _answerController.text;
    bool isUserAnswerValid = _isUserAnswerValid(userAnswer);
    if (isAnswerVisible) {
      _moveToNextQuestion(isUserAnswerValid);
      return;
    }
    if (isUserAnswerValid){
      nbSuccess++;
    } else {
      nbErrors++;
    }
    //Test if not already answered badly
    if (!_processedCardIds.contains(currentCard.id)){
      _processedCardIds.add(currentCard.id);
      _processedCards
          .add(new UserCardProcessedInfo(currentCard.id, currentCard.card.id, isUserAnswerValid));
    }
    if (isUserAnswerValid) {
      //TODO test on bunny mode instead of dummy second condition
      if (!isAnswerVisible && true) {
        setState(() {
          isAnswerVisible = true;
          _isPlayingAnimation = true;
          _validAnswerAnimControls.play("Validate");
        });
      } else {
        setState(() {
          _isPlayingAnimation = true;
          _validAnswerAnimControls.play("Validate");
        });
        _moveToNextQuestion(isUserAnswerValid);
      }
    } else {
      if (!isAnswerVisible) {
        setState(() {
          isAnswerVisible = true;
        });
      } else {
        _moveToNextQuestion(isUserAnswerValid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool toEnglish =
        currentCard != null ? currentCard.card.answerLanguageCode == 0 : false;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Review'),
      ),
      body: GestureDetector(
        onTap: () {
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
                color: Color(COLOR_GREY),
                child: Stack(
                  children: <Widget>[
                    ReviewPageInfo(
                      processedNumber: _processedCards != null ? _processedCards.length : 0,
                      remainingNumber: _remainingCards != null ? _remainingCards.length : 0,
                      isAnswerVisible: isAnswerVisible,
                      nbSuccess: nbSuccess,
                      nbErrors: nbErrors,
                    ),
                    Container(
                      child: Center(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(currentCard != null
                              ? (currentCard.card.hint ?? '')
                              : '',
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            currentCard != null
                                ? currentCard.card.question
                                : '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 24),
                          ),
                        ],
                      )),
                    )
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.black,
              height: 50,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Text(
                        toEnglish ? "ENGLISH" : "JAPANESE",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  //TODO ANIM
                  Visibility(
                    visible: _isPlayingAnimation,
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _validAnswerAnimControls.play("Validate");
                          });
                        },
                        child: FlareActor(
                            'lib/animations/checkmark_anim.flr',
                          animation: "Validate",
                          controller: _validAnswerAnimControls,
                          shouldClip: false,
                        ),
                      ),
                    ),
                  )
                ],
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
                          hintText: toEnglish ? 'Answer' : '答え',
                          labelStyle: TextStyle()),
                      textAlign: TextAlign.center,
                      autofocus: true,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_answerController.text.isNotEmpty) {
                        _processAnswer();
                      }
                    },
                    child: Container(
                      color: Color(COLOR_ORANGE),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  )
                ],
              ),
              color: Color(COLOR_GREY),
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 8, bottom: 8),
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


/*
                  Container(
                    child: InkWell(
                      child: FlareActor('lib/animations/checkmark_anim.flr'
                      ),
                    ),
                  )
 */