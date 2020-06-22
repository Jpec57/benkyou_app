import 'package:benkyou/models/DeckTheme.dart';
import 'package:benkyou/models/Sentence.dart';
import 'package:benkyou/screens/ThemePages/ThemeLearningHomePage.dart';
import 'package:benkyou/services/api/sentenceRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/utils/string.dart';
import 'package:benkyou/widgets/LoadingCircle.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/ThemeTransitionDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ThemeWritingPartPage extends StatefulWidget {
  static const routeName = '/themes/writing';
  final DeckTheme theme;

  const ThemeWritingPartPage({Key key, @required this.theme}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeWritingPartPageState();
}

class ThemeWritingPartPageState extends State<ThemeWritingPartPage> with TickerProviderStateMixin {
  Future<List<Sentence>> _sentences;
  List<Sentence> sentences;
  TextEditingController _japaneseTranslationContoller;
  bool _showAnswer = false;
  bool _isCorrect = false;
  double _currentProgressValue = 0;
  int _initSentCount = 0;
  int _nbCorrect = 0;
  int _nbFalse = 0;
  AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _japaneseTranslationContoller = new TextEditingController();
    _scaleController = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _scaleController.repeat(reverse: true);
    setSentences();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      showDialog(context: context, builder: (BuildContext context) => ThemeTransitionDialog(name: 'Writing expression'));
      Future.delayed(Duration(seconds: 3), (){
        Navigator.of(context).pop();
      });
    });
  }

  void setSentences() async{
    _sentences = getRandomThemeSentencesRequest(widget.theme.id, 2);
    sentences = await _sentences;
    _initSentCount = sentences.length;
  }

  @override
  void dispose() {
    super.dispose();
    _japaneseTranslationContoller.dispose();
  }

  _validate(Sentence sentence) {
    print(sentence.toString());
    String userAnswer = _japaneseTranslationContoller.text;
    String kanji = sentence.text;
    String kana = sentence.hint;
    if (isStringDistanceValid(kanji, userAnswer) ||
        isStringDistanceValid(kana, userAnswer)) {
      return true;
    }
    return false;
  }

  _handleSubmit() {
    _isCorrect = _validate(sentences[0]);
    if (_isCorrect) {
      print("bg");
      _nbCorrect++;
    } else {
      print("nul");
      _nbFalse++;
    }
    setState(() {
      _showAnswer = true;
      _currentProgressValue = _nbCorrect / _initSentCount;
    });
  }
/*
//        scale: Tween(begin: 0.75, end: 2.0)
//            .animate(CurvedAnimation(
//            parent: _scaleController,
//            curve: Curves.elasticOut
//        )
//        ),
 */
  Widget _renderAnswer(Sentence sentence) {
    if (_showAnswer) {
      return GestureDetector(
        onTap: (){
          if (sentences.length > 1){
            sentences.removeAt(0);
          } else {
            Navigator.of(context).pushNamed(ThemeLearningHomePage.routeName);
          }
          if (!_isCorrect){
            sentences.shuffle();
          }
          _japaneseTranslationContoller.clear();
          setState(() {
            _showAnswer = false;
          });
        },
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                color: _isCorrect ? Colors.green: Colors.red,
              ),
              width: double.infinity,
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(_isCorrect ? Icons.check : Icons.close, color: Colors.white, size: 40,),
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Center(
                                child: Text(
                                  _isCorrect ? "正解" : "違う",
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          child: Center(
                            child: Column(children: [
                              Text(
                                sentence.text,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70, fontSize: 24),
                              ),
                              Text(
                                sentence.hint,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70, fontSize: 14),
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
    return Container();
  }

  Widget _renderWritingPart() {
    String englishTranslation = sentences[0].translations[0].text;

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: _currentProgressValue,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Color(COLOR_MID_DARK_GREY),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              LocalizationWidget.of(context)
                                  .getLocalizeValue('translate'),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 26),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 30),
                              child: Center(
                                  child: Text(
                                englishTranslation,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              )),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        height: MediaQuery.of(context).size.height * 0.3),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(COLOR_DARK_BLUE),
                          border: Border(
                              top: BorderSide(
                                  width: 2, color: Color(COLOR_DARK_BLUE)))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          child: Container(
                            decoration: BoxDecoration(color: Color(0xfae6e6e6)),
                            child: TextField(
                              controller: _japaneseTranslationContoller,
                              textAlign: TextAlign.justify,
                              keyboardType: TextInputType.multiline,
                              minLines: 4,
                              maxLines: 4,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  border: InputBorder.none),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Color(COLOR_DARK_BLUE),
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      if (_showAnswer) {
                        setState(() {
                          _showAnswer = false;
                        });
                      } else {
                        _handleSubmit();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(COLOR_ORANGE),
                          border: Border.all(width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          LocalizationWidget.of(context)
                              .getLocalizeValue('check')
                              .toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ))
              ],
            ),
            //TODO
            _renderAnswer(sentences[0]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Writing'),
      ),
      body: FutureBuilder(
        future: _sentences,
        builder: (BuildContext context, AsyncSnapshot<dynamic> sentenceSnap) {
          switch (sentenceSnap.connectionState) {
            case ConnectionState.done:
              if (!sentenceSnap.hasData && sentences != null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return _renderWritingPart();
            case ConnectionState.waiting:
              return Center(
                child: Text(
                    LocalizationWidget.of(context).getLocalizeValue('loading')),
              );
            default:
              return Center(
                child: Text(
                    LocalizationWidget.of(context).getLocalizeValue('error')),
              );
          }
        },
      ),
    );
  }
}
