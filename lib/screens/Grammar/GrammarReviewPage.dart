import 'package:benkyou/models/DeckCard.dart';
import 'package:benkyou/models/GrammarPointCard.dart';
import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/models/UserCardProcessedInfo.dart';
import 'package:benkyou/screens/Grammar/GrammarDeckPage.dart';
import 'package:benkyou/screens/Grammar/GrammarDeckPageArguments.dart';
import 'package:benkyou/screens/Grammar/GrammarHomePage.dart';
import 'package:benkyou/screens/ReviewPage/LeaveReviewDialog.dart';
import 'package:benkyou/screens/ReviewPage/ReviewPageInfo.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/services/translator/TextConversion.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GrammarReviewPage extends StatefulWidget {
  static const routeName = '/grammar/review';
  final List<UserCard> cards;
  final int deckId;

  const GrammarReviewPage(
      {Key key, @required this.cards, @required this.deckId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => GrammarReviewPageState();
}

class GrammarReviewPageState extends State<GrammarReviewPage> {
  bool _isHintVisible = false;
  bool _isAnswerVisible = false;
  bool _isAnswerCorrect = false;
  List<TextEditingController> _answerControllers;
  List<UserCard> _remainingCards;
  List<UserCardProcessedInfo> _processedCards;
  List<int> _processedCardIds;
  int _previousCardId;
  UserCard currentCard;
  int _nbErrors = 0;
  int _nbSuccess = 0;

  @override
  void initState() {
    super.initState();
    _remainingCards = widget.cards;
    _processedCards = [];
    _processedCardIds = [];
    _previousCardId = 0;
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
  }

  void _goToNextQuestion(bool isCorrect) async {
    //empty text controllers
    _answerControllers.forEach((element) {
      element.clear();
    });
    setState(() {
      _isHintVisible = false;
      _isAnswerVisible = false;
    });
    //TODO REMOVE ONLY WHEN SUCCESS
    if (_remainingCards.length != 1) {
      _remainingCards.removeAt(0);
    } else {
      //TODO
      print(_processedCardIds.toString());
      print(_processedCards);
      await postReview(_processedCards);
      Navigator.of(context).pushNamed(GrammarDeckPage.routeName,
          arguments: GrammarDeckPageArguments(deckId: widget.deckId));
    }
  }

  void _handleQuestion(bool isCorrect, List<String> correctAnswers) {
    if (isCorrect) {
      _nbSuccess++;
    } else {
      _nbErrors++;
    }
    //Test if not already answered badly
    if (!_processedCardIds.contains(currentCard.id)) {
      _processedCardIds.add(currentCard.id);
      _processedCards.add(new UserCardProcessedInfo(
          currentCard.id, currentCard.card.id, isCorrect));
    }
    setState(() {
      _isAnswerCorrect = isCorrect;
      _isAnswerVisible = true;
      //SET correction in controller
      for (int i = 0; i < _answerControllers.length; i++) {
        _answerControllers[i].text = correctAnswers[i];
      }
    });
    //TODO show pop up
  }

  Future<bool> validate(String gapSentence) async {
    if (_isAnswerVisible) {
      _goToNextQuestion(_isAnswerCorrect);
    } else {
      RegExp regExp = new RegExp(r"{[^}]+}");
      Iterable<RegExpMatch> matches = regExp.allMatches(gapSentence);
      int i = 0;
      bool isCorrect = true;
      List<String> correctAnswers = [];
      for (var match in matches) {
        String desiredString =
            gapSentence.substring(match.start + 1, match.end - 1).trim();
        String givenAnswer = _answerControllers[i].text.trim();
        correctAnswers.add(desiredString);
        if (desiredString != givenAnswer &&
            getHiragana(givenAnswer) != desiredString &&
            getKatakana(givenAnswer) != desiredString) {
          isCorrect = false;
        }
        i++;
      }
      _handleQuestion(isCorrect, correctAnswers);
    }
    return true;
  }

  Widget _renderQuestionWithGap(
      int currentCardId, GrammarPointCard grammarCard) {
    bool hasCardChanged = currentCardId != _previousCardId;
    _previousCardId = currentCardId;
    // TODO take random
    String gapSentence = grammarCard.gapSentences[0];
    List<Widget> widgets = [];
    int length = gapSentence.length;
    int controllerIndex = 0;
    if (hasCardChanged) {
      _answerControllers = [];
    }
    for (int i = 0; i < length; i++) {
      var char = gapSentence[i];
      int subStrStartSize = 0;
      while (char != '{' && i + subStrStartSize < length) {
        char = gapSentence[i + subStrStartSize];
        subStrStartSize++;
      }
      if (subStrStartSize > 0) {
        widgets.add(Text(
          gapSentence.substring(i, i + subStrStartSize - 1),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ));
      }
      i += subStrStartSize;
      subStrStartSize = 0;
      if (char == '{') {
        while (char != '}' && i + subStrStartSize < length) {
          char = gapSentence[i + subStrStartSize];
          subStrStartSize++;
        }
        //because we have here a letter different from '}'
        subStrStartSize--;
        if (hasCardChanged) {
          _answerControllers.add(new TextEditingController());
        }
        widgets.add(Container(
          height: 40,
          child: IntrinsicWidth(
            child: TextFormField(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: -15.0),
                  hintText: "(${controllerIndex + 1})"),
              textAlign: TextAlign.center,
              enabled: !_isAnswerVisible,
              textAlignVertical: TextAlignVertical.top,
              controller: _answerControllers[controllerIndex],
              style: TextStyle(
                  fontSize: 20,
                  color: _isAnswerVisible
                      ? _isAnswerCorrect ? Colors.green : Colors.red
                      : Colors.blue),
            ),
          ),
        ));
        controllerIndex++;
      }
      i += subStrStartSize;
    }

    return Wrap(
        runAlignment: WrapAlignment.center,
        alignment: WrapAlignment.center,
        direction: Axis.horizontal,
        children: widgets);
  }

  Widget _renderHeader(UserCard card, bool isKeyboardVisible) {
    DeckCard deckCard = card.card;
    GrammarPointCard grammarCard = card.grammarCard;
    currentCard = card;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Visibility(
          visible: !isKeyboardVisible,
          child: ReviewPageInfo(
            nbErrors: _nbErrors,
            nbSuccess: _nbSuccess,
            remainingNumber: _remainingCards.length,
            isAnswerVisible: _isAnswerVisible,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: _renderQuestionWithGap(card.id, grammarCard),
        ),
        Visibility(
          visible: !isKeyboardVisible,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: Visibility(
                      visible: _isHintVisible,
                      child: Center(
                          child: Text(
                        deckCard.hint,
                        textAlign: TextAlign.justify,
                      )))),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      _isHintVisible = true;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.wb_incandescent),
                  )),
            ],
          ),
        ),
        Container(
          color: Colors.black,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                "Complete this sentence",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _renderTextFormFields(List<TextEditingController> controllers) {
    List<Widget> list = [];
    for (int i = 0; i < controllers.length; i++) {
      list.add(Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: TextFormField(
              controller: controllers[i],
              decoration:
                  InputDecoration(hintText: "Answer for field (${i + 1})"),
              enabled: !_isAnswerVisible,
            ),
          ),
        ),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Grammar review'),
        leading: IconButton(
          onPressed: () {
            if (_processedCards == null || _processedCards.length == 0) {
              if (widget.deckId != null) {
                Navigator.pushNamedAndRemoveUntil(
                    context,
                    GrammarDeckPage.routeName,
                    ModalRoute.withName(GrammarDeckPage.routeName),
                    arguments: GrammarDeckPageArguments(deckId: widget.deckId));
              } else {
                Navigator.pushNamedAndRemoveUntil(
                    context,
                    GrammarHomePage.routeName,
                    ModalRoute.withName(GrammarHomePage.routeName));
              }
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => LeaveReviewDialog(
                        processedCards: _processedCards,
                        deckId: widget.deckId,
                        isVocab: false,
                      ));
            }
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _renderHeader(_remainingCards[0], isKeyboardVisible),
            Expanded(
                child: Container(
              color: Color(COLOR_DARK_GREY),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 15, left: 15.0, right: 15, bottom: 50),
                        child: Column(
                          children: _renderTextFormFields(_answerControllers),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !isKeyboardVisible,
                    child: GestureDetector(
                      onTap: () {
                        validate(
                            _remainingCards[0].grammarCard.gapSentences[0]);
                      },
                      child: Container(
                        color: Color(COLOR_ORANGE),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Center(
                            child: Text(
                              "Confirm".toUpperCase(),
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
