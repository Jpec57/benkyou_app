import 'dart:math';

import 'package:benkyou/models/Answer.dart';
import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/models/UserCardProcessedInfo.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/screens/DeckPage/DeckPage.dart';
import 'package:benkyou/screens/DeckPage/DeckPageArguments.dart';
import 'package:benkyou/screens/ReviewPage/LeaveReviewDialog.dart';
import 'package:benkyou/screens/ReviewPage/ReviewPageInfo.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/services/translator/TextConversion.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/utils/string.dart';
import 'package:benkyou/widgets/CompleteTextDialog.dart';
import 'package:benkyou/widgets/LoadingCircle.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class ReviewPage extends StatefulWidget {
  static const routeName = '/review';

  final List<UserCard> cards;
  final int deckId;

  const ReviewPage({Key key, @required this.cards, this.deckId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewPage> {
  bool isAnswerVisible = false;
  bool isAnswerCorrect = false;
  bool _isPlayingAnimation = false;
  final FlareControls _validAnswerAnimControls = FlareControls();
  final FlareControls _incorrectAnswerAnimControls = FlareControls();

  FocusNode _focusNode;
  TextEditingController _answerController;
  List<UserCard> _remainingCards;
  List<int> _processedCardIds;
  List<UserCardProcessedInfo> _processedCards;
  int currentIndex;
  int nbErrors = 0;
  int nbSuccess = 0;
  UserCard currentCard;
  FlutterTts _flutterTts;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _remainingCards = widget.cards;
    _processedCards = [];
    _processedCardIds = [];
    currentIndex = generateRandomIndex(_remainingCards);
    currentCard = _remainingCards[currentIndex];
    //first card
    initializeTts();
    _answerController = new TextEditingController();
    _focusNode = new FocusNode();
  }

  void updateCurrentUserCard(UserCard updatedCard){
    _remainingCards[currentIndex] = updatedCard;
    setState(() {
      currentCard = updatedCard;
    });
  }

  initializeTts() {
    _flutterTts = FlutterTts();

    _flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });

    _flutterTts.setErrorHandler((err) {
      setState(() {
        print("error occurred: " + err);
        isPlaying = false;
      });
    });
    bool toEnglish = currentCard.card.answerLanguageCode == 0;
    String toSpeak = currentCard.card.question.split(',')[0];
    _speak(toSpeak, toEnglish ? "ja-JP" : "en-GB");
  }

  Future _speak(String text, String languageCode) async {
    await setTtsLanguage(languageCode);
    if (text != null && text.isNotEmpty) {
      var result = await _flutterTts.speak(text);
      if (result == 1)
        setState(() {
          isPlaying = true;
        });
    }
  }

  Future<void> setTtsLanguage(String languageCode) async {
    await _flutterTts.setLanguage(languageCode);
  }

  Future _stop() async {
    var result = await _flutterTts.stop();
    if (result == 1)
      setState(() {
        isPlaying = false;
      });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _flutterTts.stop();
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

  Widget _renderUserNotes(String userNote) {
    if (userNote != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(currentCard.userNote),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.add_circle),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(LocalizationWidget.of(context).getLocalizeValue('edit_note')),
                ),
              ],
            ),
          )
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(Icons.add_circle),
        ),
        Text(LocalizationWidget.of(context).getLocalizeValue('add_note')),
      ],
    );
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
          Text(LocalizationWidget.of(context)
              .getLocalizeValue('possible_answers')),
          Divider(
            thickness: 1,
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 8.0, left: 8, right: 8, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _renderAnswers(currentCard.card.answers),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: GestureDetector(
                onTap: (){
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => CompleteTextDialog(
                        text: '', positiveCallback: (text) async{
                          UserCard updatedUserCard = await addUserAnswer(currentCard.id, text);
                          if (updatedUserCard != null){
                            updateCurrentUserCard(updatedUserCard);
                          } else {
                            Get.snackbar(LocalizationWidget.of(context).getLocalizeValue('error'), LocalizationWidget.of(context).getLocalizeValue('generic_error'), snackPosition: SnackPosition.BOTTOM);
                          }
                      },
                      ));
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.add_circle),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(LocalizationWidget.of(context).getLocalizeValue('add_note')),
                    ),
                  ],
                ),
              ),
            ),
          ),


          Text(LocalizationWidget.of(context).getLocalizeValue('users_note')),
          Divider(
            thickness: 1,
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: (){
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => CompleteTextDialog(
                        text: currentCard.userNote, positiveCallback: (text) async{
                          UserCard updatedUserCard = await postUserNote(currentCard.id, text);
                          if (updatedUserCard != null){
                            updateCurrentUserCard(updatedUserCard);
                          } else {
                            Get.snackbar(LocalizationWidget.of(context).getLocalizeValue('error'), LocalizationWidget.of(context).getLocalizeValue('generic_error'), snackPosition: SnackPosition.BOTTOM);
                          }
                      },
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: _renderUserNotes(currentCard.userNote),
                ),
              ),
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
    showLoadingDialog(context);
    await postReview(reviewedCards);
    Navigator.pop(context);
  }

  _moveToNextQuestion(bool isAnswerCorrect) async {
    isAnswerVisible = false;
    _isPlayingAnimation = false;
    //Remove only if correct
    if (isAnswerCorrect) {
      _remainingCards.removeAt(currentIndex);
    }
    int length = _remainingCards.length;
    if (length > 0) {
      currentIndex = (length == 1) ? 0 : generateRandomIndex(_remainingCards);
      currentCard = _remainingCards[currentIndex];
      bool toEnglish = currentCard.card.answerLanguageCode == 0;
      String toSpeak = currentCard.card.question.split(',')[0];
      _speak(toSpeak, toEnglish ? "ja-JP" : "en-GB");
    } else {
      await _sendReview(_processedCards);
      Navigator.pushReplacementNamed(context, DeckPage.routeName,
          arguments: DeckPageArguments(currentCard.deck.id));
    }
    FocusScope.of(context).requestFocus(_focusNode);
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
    isAnswerCorrect = isUserAnswerValid;
    if (isUserAnswerValid) {
      nbSuccess++;
    } else {
      nbErrors++;
    }
    //Test if not already answered badly
    if (!_processedCardIds.contains(currentCard.id)) {
      _processedCardIds.add(currentCard.id);
      _processedCards.add(new UserCardProcessedInfo(
          currentCard.id, currentCard.card.id, isUserAnswerValid));
    }
    _isPlayingAnimation = true;

    if (isUserAnswerValid) {
      //TODO test on bunny mode instead of dummy second condition
      if (!isAnswerVisible && true) {
        setState(() {
          isAnswerVisible = true;
          _validAnswerAnimControls.play("Untitled");
        });
      } else {
        setState(() {
          _validAnswerAnimControls.play("Untitled");
        });
        _moveToNextQuestion(isUserAnswerValid);
      }
    } else {
      if (!isAnswerVisible) {
        setState(() {
          isAnswerVisible = true;
          _incorrectAnswerAnimControls.play("Error");
        });
      } else {
        _moveToNextQuestion(isUserAnswerValid);
      }
    }
  }

  Color _setFieldColor() {
    if (isAnswerVisible) {
      if (isAnswerCorrect) {
        return Colors.green;
      } else {
        return Colors.red;
      }
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    bool toEnglish =
        currentCard != null ? currentCard.card.answerLanguageCode == 0 : false;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(LocalizationWidget.of(context).getLocalizeValue('review')),
        leading: IconButton(
          onPressed: () {
            if (_processedCards == null || _processedCards.length == 0){
              if (widget.deckId != null){
                Navigator.pushReplacementNamed(context, DeckPage.routeName, arguments: DeckPageArguments(widget.deckId));
              } else {
                Navigator.pushReplacementNamed(context, DeckHomePage.routeName);
              }
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => LeaveReviewDialog(
                      processedCards: _processedCards, deckId: widget.deckId));
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
          children: <Widget>[
            IntrinsicHeight(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.2
                ),
                color: Color(COLOR_GREY),
                child: Stack(
                  children: <Widget>[
                    Align(
                      child: GestureDetector(
                        onTap: () {
                          String toSpeak = currentCard != null
                              ? currentCard.card.question.split(',')[0] : '';
                          isPlaying
                              ? _stop()
                              : _speak(
                                  toSpeak,
                                  toEnglish ? "ja-JP" : "en-GB");
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.volume_up,
                            size: 35,
                          ),
                        ),
                      ),
                      alignment: Alignment.bottomRight,
                    ),
                    ReviewPageInfo(
                      remainingNumber:
                          _remainingCards != null ? _remainingCards.length : 0,
                      isAnswerVisible: isAnswerVisible,
                      nbSuccess: nbSuccess,
                      nbErrors: nbErrors,
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              currentCard != null
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
                      ),
                    )
                  ],
                ),
              ),
            ),
            IntrinsicHeight(
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          (toEnglish
                              ? LocalizationWidget.of(context)
                              .getLocalizeValue('english')
                              : LocalizationWidget.of(context)
                              .getLocalizeValue('japanese'))
                              .toUpperCase(),
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: _isPlayingAnimation && isAnswerCorrect ? 1 : 0,
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _validAnswerAnimControls.play("Untitled");
                              });
                            },
                            child: FlareActor(
                              'lib/animations/correct_check.flr',
                              animation: "Untitled",
                              controller: _validAnswerAnimControls,
                              shouldClip: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: _isPlayingAnimation && !isAnswerCorrect ? 1 : 0,
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _incorrectAnswerAnimControls.play("Error");
                              });
                            },
                            child: FlareActor(
                              'lib/animations/wrong_answer.flr',
                              animation: "Error",
                              controller: _incorrectAnswerAnimControls,
                              shouldClip: false,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: _setFieldColor(),
                      child: TextFormField(
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.go,
                        autocorrect: false,
                        onFieldSubmitted: (value) {
                          if (_answerController.text.isNotEmpty) {
                            _processAnswer();
                          }
                        },
                        controller: _answerController,
                        decoration: InputDecoration(
                          hintText: toEnglish
                              ? LocalizationWidget.of(context)
                                  .getLocalizeValue('answer')
                              : '答え',
                          labelStyle: TextStyle(),
                        ),
                        textAlign: TextAlign.center,
                        autofocus: true,
                      ),
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
