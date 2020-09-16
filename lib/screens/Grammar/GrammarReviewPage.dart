import 'dart:math';

import 'package:benkyou/models/DeckCard.dart';
import 'package:benkyou/models/GrammarPointCard.dart';
import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/models/UserCardProcessedInfo.dart';
import 'package:benkyou/screens/Grammar/GrammarDeckPage.dart';
import 'package:benkyou/screens/Grammar/GrammarDeckPageArguments.dart';
import 'package:benkyou/screens/Grammar/GrammarHomePage.dart';
import 'package:benkyou/screens/HomePage/HomePage.dart';
import 'package:benkyou/screens/ReviewPage/LeaveReviewDialog.dart';
import 'package:benkyou/screens/ReviewPage/ReviewPageInfo.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/services/translator/TextConversion.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/utils/random.dart';
import 'package:benkyou/widgets/GrammarPointWidget.dart';
import 'package:benkyou/widgets/KanaTextForm.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class GrammarReviewPage extends StatefulWidget {
  static const routeName = '/grammar/review';
  final List<UserCard> cards;
  final int deckId;
  final bool isFromHomePage;

  const GrammarReviewPage(
      {Key key, @required this.cards, this.deckId, this.isFromHomePage = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => GrammarReviewPageState();
}

class GrammarReviewPageState extends State<GrammarReviewPage> {
  bool _isHintVisible = false;
  bool _isAnswerVisible = false;
  bool _isAnswerCorrect = false;
  bool _isEditing = true;
  String _error;
  List<TextEditingController> _answerControllers;
  List<TextEditingController> _possibleAnswers;
  List<Widget> gapWidgets = [];
  List<FocusNode> _focusNodes;
  List<UserCard> _remainingCards;
  List<UserCardProcessedInfo> _processedCards;
  List<int> _processedCardIds;
  int _previousCardId;
  UserCard currentCard;
  int _nbErrors = 0;
  int _nbSuccess = 0;
  int _sentenceIndex = 0;
  final _formKey = GlobalKey<FormState>();

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
    for (var node in _focusNodes) {
      node.dispose();
    }
  }

  void _handleNavigation() {
    if (widget.deckId != null) {
      Navigator.pushNamedAndRemoveUntil(context, GrammarDeckPage.routeName,
          ModalRoute.withName(GrammarDeckPage.routeName),
          arguments: GrammarDeckPageArguments(deckId: widget.deckId));
    } else {
      if (widget.isFromHomePage) {
        Navigator.pushNamedAndRemoveUntil(context, HomePage.routeName,
            ModalRoute.withName(HomePage.routeName));
      } else {
        Navigator.pushNamedAndRemoveUntil(context, GrammarHomePage.routeName,
            ModalRoute.withName(GrammarHomePage.routeName));
      }
    }
  }

  void _goToNextQuestion(bool isCorrect) async {
    gapWidgets = [];
    //empty text controllers
    _answerControllers.forEach((element) {
      element.clear();
    });
    if (isCorrect) {
      if (_remainingCards.length != 1) {
        _remainingCards.removeAt(0);
      } else {
        await postReview(_processedCards);
        _handleNavigation();
      }
    } else {
      _remainingCards.shuffle(new Random());
    }
    setState(() {
      _isHintVisible = false;
      _isAnswerVisible = false;
      _error = null;
    });
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
      // SET correction in controller
      for (int i = 0; i < _answerControllers.length; i++) {
        _answerControllers[i].text = correctAnswers[i];
      }
    });
  }

  bool isAnswerCorrect(List<String> acceptedAnswers, String givenAnswer) {
    for (String accepted in acceptedAnswers) {
      String replacement = "ありません";
      RegExp exp = new RegExp(r"ない$");
      RegExpMatch res = exp.firstMatch(accepted);
      String politeAcceptedOption;
      if (res != null) {
        politeAcceptedOption = (accepted.substring(0, res.start) + replacement);
      }
      print("politeDesiredString $politeAcceptedOption");

      if (givenAnswer == politeAcceptedOption ||
          accepted == givenAnswer ||
          getHiragana(givenAnswer) == accepted ||
          getKatakana(givenAnswer) == accepted) {
        return true;
      }
    }
    return false;
  }

  Future<bool> validate(String gapSentence) async {
    if (_isAnswerVisible) {
      _goToNextQuestion(_isAnswerCorrect);
    } else {
      bool isFormComplete = _formKey.currentState.validate();
      if (!isFormComplete) {
        return false;
      }
      RegExp regExp = new RegExp(r"{[^}]+}");
      Iterable<RegExpMatch> matches = regExp.allMatches(gapSentence);
      int i = 0;
      bool isCorrect = true;
      List<String> correctAnswers = [];
      for (var match in matches) {
        String givenAnswer = _answerControllers[i].text.trim();

        List<String> acceptedAnswers = [];
        String desiredString =
            gapSentence.substring(match.start + 1, match.end - 1).trim();
        if (desiredString.contains('/')) {
          acceptedAnswers = desiredString.split('/');
        } else {
          acceptedAnswers.add(desiredString);
        }
        List<String> synonyms = _remainingCards[0].grammarCard.acceptedAnswers;
        if (synonyms.length > 0) {
          acceptedAnswers.addAll(synonyms);
        }
        isCorrect = isAnswerCorrect(acceptedAnswers, givenAnswer);
        var rand = new Random();
        int length = acceptedAnswers.length;
        String a = (length > 2)
            ? acceptedAnswers[rand.nextInt(length)]
            : acceptedAnswers[0];
        correctAnswers.add(a);
        _answerControllers[i].text = a;
        i++;
      }
      _handleQuestion(isCorrect, correctAnswers);
    }
    return true;
  }

  //todo
  Widget renderGapUpdateWidget() {
    print("_sentenceIndex $_sentenceIndex");
    if (gapWidgets.isEmpty) {
      String gapSentence =
          _remainingCards[0].grammarCard.gapSentences[_sentenceIndex];
      RegExp regExp = new RegExp(r"{[^}]+}");
      Iterable<RegExpMatch> matches = regExp.allMatches(gapSentence);
      int i = 1;
      List<FocusNode> nodes = [];
      _possibleAnswers = [];
      for (var match in matches) {
        String desiredString =
            gapSentence.substring(match.start + 1, match.end - 1).trim();
        gapWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8),
            child: Text(
              'Gap $i:',
            ),
          ),
        );

        FocusNode focusNode = new FocusNode();
        nodes.add(focusNode);

        TextEditingController _answerController = new TextEditingController();
        _possibleAnswers.add(_answerController);
        gapWidgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 8, top: 8),
          child: KanaTextForm(
            boxDecoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              border: Border.all(color: Colors.grey),
            ),
            controller: _answerController,
            focusNode: focusNode,
            isReadOnly: false,
            autofocus: false,
          ),
        ));
        _answerController.value = _answerController.value.copyWith(
            text: desiredString,
            composing: TextRange(start: 0, end: desiredString.length),
            selection: TextSelection(
                baseOffset: desiredString.length,
                extentOffset: desiredString.length));
        i++;
      }
    }
    GrammarPointCard grammarPointCard = _remainingCards[0].grammarCard;
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Color(COLOR_ORANGE), shape: BoxShape.circle),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.edit,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _isEditing,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Possible answers:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                ...gapWidgets,
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  color: Color(COLOR_ANTRACITA),
                  child: Text(
                    "Update".toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    RegExp regExp = new RegExp(r"{[^}]+}");
                    String newSentence =
                        grammarPointCard.gapSentences[_sentenceIndex];
                    for (var controller in _possibleAnswers) {
                      newSentence = newSentence.replaceFirst(
                          regExp, "{${controller.text}}");
                    }
                    List<String> gSentList = grammarPointCard.gapSentences;
                    gSentList[_sentenceIndex] = newSentence;
                    grammarPointCard.gapSentences = gSentList;
                    await postGrammarCard(
                        currentCard.deck.id, grammarPointCard.toJson());
                    Get.snackbar(
                        "Success", "Your card has correctly been updated");
                    setState(() {
                      _isEditing = false;
                    });
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderQuestionWithGap(
      int currentCardId, GrammarPointCard grammarCard) {
    bool hasCardChanged = currentCardId != _previousCardId;
    _previousCardId = currentCardId;
    if (hasCardChanged) {
      _sentenceIndex = generateRandomIndex(grammarCard.gapSentences);
    }
    String gapSentence = grammarCard.gapSentences[_sentenceIndex];
    List<Widget> widgets = [];
    int length = gapSentence.length;
    int controllerIndex = 0;
    if (hasCardChanged) {
      _answerControllers = [];
      _focusNodes = [];
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
          _focusNodes.add(new FocusNode());
        }
        widgets.add(Container(
          height: 30,
          child: IntrinsicWidth(
            child: TextFormField(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: -15.0),
                  hintText: "(${controllerIndex + 1})"),
              textAlign: TextAlign.center,
              enabled: false,
              textAlignVertical: TextAlignVertical.top,
              autofocus: false,
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
    String currentMeaning = deckCard.hint ??
        (deckCard.answers != null && deckCard.answers.isNotEmpty
            ? deckCard.answers[0].text
            : null);

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
          visible:
              !isKeyboardVisible && currentMeaning != null && !_isAnswerVisible,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: Visibility(
                      visible: _isHintVisible,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 15),
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 1.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(1.0,
                                      1.0), // shadow direction: bottom right
                                )
                              ],
                              color: Colors.white,
                              border: Border.all(color: Colors.black87),
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Center(
                                child: Text(
                              currentMeaning,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black45),
                            )),
                          ),
                        ),
                      ))),
              Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                  child: ClipOval(
                    child: Material(
                      child: InkWell(
                        splashColor: Color(COLOR_DARK_BLUE), // inkwell color
                        child: SizedBox(
                            width: 30,
                            height: 30,
                            child: Icon(Icons.wb_incandescent)),
                        onTap: () {
                          setState(() {
                            _isHintVisible = true;
                          });
                        },
                      ),
                    ),
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
                _isAnswerVisible
                    ? deckCard.question
                    : "Complete this sentence".toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }

  void checkAnswers() {
    bool isEmpty = false;
    for (var controller in _answerControllers) {
      if (controller.text.isEmpty) {
        setState(() {
          _error =
              LocalizationWidget.of(context).getLocalizeValue('fields_empty');
        });
        isEmpty = true;
        return;
      }
    }

    if (!isEmpty) {
      validate(_remainingCards[0].grammarCard.gapSentences[_sentenceIndex]);
    }
  }

  List<Widget> _renderTextFormFields(List<TextEditingController> controllers) {
    List<Widget> list = [];
    int controllerLength = controllers.length;
    if (_error != null) {
      list.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          child: Text(
            _error,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ));
    }
    for (int i = 0; i < controllerLength - 1; i++) {
      list.add(Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text("(${i + 1})"),
                ),
                Flexible(
                  child: KanaTextForm(
                    controller: controllers[i],
                    boxDecoration: BoxDecoration(),
                    isReadOnly: _isAnswerVisible,
                    autofocus: i == 0,
                    focusNode: _focusNodes[i],
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    }
    list.add(Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text("($controllerLength)"),
                ),
                Flexible(
                  child: KanaTextForm(
                    controller: controllers[controllerLength - 1],
                    boxDecoration: BoxDecoration(),
                    isReadOnly: _isAnswerVisible,
                    autofocus: false,
                    focusNode: _focusNodes[controllerLength - 1],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    checkAnswers();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Color(COLOR_ANTRACITA),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(3),
                              bottomRight: Radius.circular(3))),
                      height: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.navigate_next,
                          color: Colors.white,
                          size: 30,
                        ),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    ));
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
              _handleNavigation();
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => LeaveReviewDialog(
                        navigationFunctionHandler: _handleNavigation,
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
              color: Color(COLOR_LIGHT_GREY),
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
                        child: _isAnswerVisible
                            ? Column(
                                children: [
                                  GrammarPointCardWidget(
                                      card: _remainingCards[0].card,
                                      grammarCard:
                                          _remainingCards[0].grammarCard),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: renderGapUpdateWidget(),
                                  )
                                ],
                              )
                            : Form(
                                key: _formKey,
                                child: Column(
                                  children:
                                      _renderTextFormFields(_answerControllers),
                                ),
                              ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !isKeyboardVisible,
                    child: GestureDetector(
                      onTap: () {
                        checkAnswers();
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
