import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:benkyou/models/DeckTheme.dart';
import 'package:benkyou/models/Sentence.dart';
import 'package:benkyou/screens/ThemePages/ThemeLearningHomePage.dart';
import 'package:benkyou/screens/ThemePages/Writing/ThemeWritingPartPage.dart';
import 'package:benkyou/screens/ThemePages/Writing/ThemeWritingPartPageArguments.dart';
import 'package:benkyou/services/api/sentenceRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/utils/string.dart';
import 'package:benkyou/widgets/ConfirmDialog.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/ThemeListeningPlayerWidget.dart';
import 'package:benkyou/widgets/ThemeTransitionDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeListeningPartPage extends StatefulWidget {
  static const routeName = '/themes/listening';
  final DeckTheme chosenTheme;

  const ThemeListeningPartPage({Key key, @required this.chosenTheme})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeListeningPartPageState();
}

class ThemeListeningPartPageState extends State<ThemeListeningPartPage>
    with SingleTickerProviderStateMixin {
  Future<List<Sentence>> _sentences;
  List<Sentence> sentences;
  List<List<String>> _possibleAnswersPerSentence;
  double _currentProgressValue = 0;
  double _badOpacity = 1;
  bool _isCorrect = false;
  double _answerContainerHeight = 0;
  int _nbSuccess = 0;
  int _nbErrors = 0;
  int nbSentences;

  @override
  void initState() {
    super.initState();
    _initSentences();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              ThemeTransitionDialog(name: 'Listening comprehension'));
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    });
  }

  void _initSentences() async {
    _sentences = getRandomThemeSentencesRequest(widget.chosenTheme.id, 2);
    sentences = await _sentences;
    _possibleAnswersPerSentence =
        _generatePossibleAnswersForSentences(sentences);
    nbSentences = sentences.length;
  }

  void _handleAnswer(isAnswer) {
    if (isAnswer) {
      _nbSuccess++;
      _isCorrect = true;
    } else {
      _isCorrect = false;
      _nbErrors++;
    }
    setState(() {
      _badOpacity = 0;
      _answerContainerHeight = MediaQuery.of(context).size.height * 0.4;
      _currentProgressValue = (_nbErrors + _nbSuccess) / nbSentences;
    });
  }

  Widget _renderAnswerTile(String possibleAnswer, bool isAnswer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: GestureDetector(
          onTap: () {
            _handleAnswer(isAnswer);
          },
          child: Container(
            color: Color(COLOR_ANTRACITA),
            child: ListTile(
              title: Center(
                child: Text("$possibleAnswer",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  __renderPossibleAnswerTile(String possibleAnswer, bool isAnswer) {
    if (isAnswer) {
      return _renderAnswerTile(possibleAnswer, true);
    }
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: _badOpacity,
      child: _renderAnswerTile(possibleAnswer, false),
    );
  }

  List<List<String>> _generatePossibleAnswersForSentences(
      List<Sentence> sentences) {
    Random random = new Random();
    List<List<String>> answersForSentences = [];
    for (Sentence sent in sentences) {
      String answer = sent.hint != null ? sent.hint : sent.text;
      List<String> possibleAnswers = [
        answer,
        ...getSentenceBadVariations(answer)
      ];
      possibleAnswers.shuffle(random);
      answersForSentences.add(possibleAnswers);
    }
    return answersForSentences;
  }

  Widget _renderListeningPage(Sentence sentence, List<String> possibleAnswers) {
    String answer = sentence.hint != null ? sentence.hint : sentence.text;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: LinearProgressIndicator(
                value: _currentProgressValue,
              ),
            ),
            ThemeListeningPlayerWidget(sentence: sentence),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: Text(
                        LocalizationWidget.of(context)
                            .getLocalizeValue('what_did_hear'),
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Expanded(
                        flex: 5,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: possibleAnswers.length,
                            itemBuilder: (context, index) {
                              return __renderPossibleAnswerTile(
                                  possibleAnswers[index],
                                  possibleAnswers[index] == answer);
                            }))
                  ],
                ),
              ),
            ),
          ],
        ),
        _renderAnswer(sentence)
      ],
    );
  }

  Widget _renderAnswer(Sentence sentence) {
    return GestureDetector(
      onTap: () {
        if (sentences.length > 1) {
          sentences.removeAt(0);
          _possibleAnswersPerSentence.removeAt(0);
        } else {
          Navigator.of(context).pushNamed(ThemeWritingPartPage.routeName,
              arguments: ThemeWritingPartPageArguments(widget.chosenTheme));
        }
        setState(() {
          _answerContainerHeight = 0;
          _badOpacity = 1;
        });
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: AnimatedSize(
            duration: Duration(seconds: 1),
            curve: Curves.elasticOut,
            vsync: this,
            child: Container(
              decoration: BoxDecoration(
                color: _isCorrect ? Colors.green : Colors.red,
              ),
              height: _answerContainerHeight,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            _isCorrect ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Center(
                              child: Text(
                                _isCorrect ? "正解" : "違う",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        child: Center(
                          child: Column(children: [
                            Text(
                              sentence.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 20),
                            ),
                            Text(
                              sentence.hint,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.dialog(ConfirmDialog(
          action:
              LocalizationWidget.of(context).getLocalizeValue('quit_session'),
          positiveCallback: () async {
            Navigator.of(context).pushNamedAndRemoveUntil(
                ThemeLearningHomePage.routeName,
                ModalRoute.withName(ThemeLearningHomePage.routeName));
          },
          shouldAlwaysPop: false,
        ));
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(LocalizationWidget.of(context).getLocalizeValue('dialog')),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: FutureBuilder(
            future: _sentences,
            builder: (BuildContext context,
                AsyncSnapshot<List<Sentence>> sentenceSnapshot) {
              switch (sentenceSnapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: Text(LocalizationWidget.of(context)
                        .getLocalizeValue('loading')),
                  );
                case ConnectionState.done:
                  if (sentences != null && sentences.length > 0) {
                    return _renderListeningPage(
                        sentences[0], _possibleAnswersPerSentence[0]);
                  }
                  return Center(
                      child: Text(LocalizationWidget.of(context)
                          .getLocalizeValue('generic_error')));
                default:
                  return Center(
                    child: Text(LocalizationWidget.of(context)
                        .getLocalizeValue('empty')),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
