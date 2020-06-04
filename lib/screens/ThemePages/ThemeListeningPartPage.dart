import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:benkyou/models/Sentence.dart';
import 'package:benkyou/services/api/sentenceRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:benkyou/widgets/ThemeListeningPlayerWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'ThemeLearningHomePage.dart';

class ThemeListeningPartPage extends StatefulWidget {
  static const routeName = '/themes/listening';
  final int chosenThemeId;

  const ThemeListeningPartPage({Key key, @required this.chosenThemeId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeListeningPartPageState();
}

class ThemeListeningPartPageState extends State<ThemeListeningPartPage>
    with SingleTickerProviderStateMixin {
  Future<List<Sentence>> _sentences;
  List<Sentence> _loadedSentences;
  int nbSentences;
  Future<List<List<String>>> _possibleAnswersPerSentence;
  int _currentIndex = 0;
  double _currentProgressValue = 0;
  double _badOpacity = 1;


  @override
  void initState() {
    super.initState();
    _initSentences();
  }

  void _initSentences() async {
    _sentences = getRandomThemeSentencesRequest(widget.chosenThemeId, 5);
    _possibleAnswersPerSentence = _generatePossibleAnswersForSentences(_sentences);
  }


  void _handleAnswer(){
    setState(() {
      _badOpacity = 0;
    });
    Future.delayed(Duration(seconds: 3), (){
      if (_currentIndex + 1 < nbSentences){
        setState(() {
          _currentIndex = _currentIndex + 1;
          _badOpacity = 1;
        });
      } else {
        Navigator.of(context).pushNamed(ThemeLearningHomePage.routeName);
      }
    });
  }

  Widget _renderAnswerTile(String possibleAnswer){
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: GestureDetector(
          onTap: () {
            _handleAnswer();
          },
          child: Container(
            color: Colors.blueGrey,
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
    if (isAnswer){
      return _renderAnswerTile(possibleAnswer);
    }
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: _badOpacity,
      child: _renderAnswerTile(possibleAnswer),
    );
  }

  Future<List<List<String>>> _generatePossibleAnswersForSentences(Future<List<Sentence>> sentences) async{
    List<Sentence> sents = await sentences;
    _loadedSentences = sents;
    nbSentences = _loadedSentences.length;
    Random random = new Random();
    List<List<String>> answersForSentences = [];
    for (Sentence sent in sents){
      String answer = sent.text;
      List<String> possibleAnswers = [
        answer,
        "${answer}a",
        "${answer}b",
        "${answer}c"
      ];
      possibleAnswers.shuffle(random);
      answersForSentences.add(possibleAnswers);
    }
    return answersForSentences;
  }

  Widget _renderListeningPage(Sentence sentence, List<String> possibleAnswers) {
    return Column(
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
                              possibleAnswers[index], possibleAnswers[index] == sentence.text);
                        }))
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationWidget.of(context).getLocalizeValue('dialog')),
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
                List<Sentence> sentences = sentenceSnapshot.data;

                print(sentences);
                if (sentences != null && sentences.length > 0) {
                  return FutureBuilder(
                    future: _possibleAnswersPerSentence,
                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                        switch (snapshot.connectionState){
                          case ConnectionState.done:
                            List<List<String>> possibleAnswersPerSentence = snapshot.data;
                            return _renderListeningPage(sentences[_currentIndex], possibleAnswersPerSentence[_currentIndex]);
                        case ConnectionState.none:
                            return Center(
                              child: Text(
                                  LocalizationWidget.of(context).getLocalizeValue('generic_error')),
                            );
                          default:
                            return Center(
                              child: Text(
                                  LocalizationWidget.of(context).getLocalizeValue('empty')),
                            );
                        }
                      });
                }
                return Center(
                  child: Text(
                      LocalizationWidget.of(context).getLocalizeValue('generic_error')));
              default:
                return Center(
                  child: Text(
                      LocalizationWidget.of(context).getLocalizeValue('empty')),
                );
            }
          },
        ),
      ),
    );
  }
}
