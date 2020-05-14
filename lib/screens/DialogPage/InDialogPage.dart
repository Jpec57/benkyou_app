import 'dart:async';
import 'dart:ui';
import 'package:benkyou/models/DialogText.dart';
import 'package:benkyou/models/UserDialog.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/services/api/dialogRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/utils/random.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class InDialogPage extends StatefulWidget {
  static const routeName = '/dialog/in';

  @override
  State<StatefulWidget> createState() => InDialogPageState();
}

enum TtsState { playing, stopped }

class InDialogPageState extends State<InDialogPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TabController _tabController;
  bool isDialogStarted = false;
  Future<UserDialog> dialog;
  FlutterTts _flutterTts;
  bool isRecordPlaying = false;
  bool isListening = false;
  bool isAnswerSelected = false;
  DialogText currentDialog;
  TtsState ttsState = TtsState.stopped;
  DialogText selectedAnswer;
  TextEditingController _answerInputController;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _initDialog();
    initializeTts();
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.index = 1;
    _answerInputController = new TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _flutterTts.stop();
    _tabController.dispose();
    _answerInputController.dispose();
  }

  void _initDialog() async {
    dialog = getDialogRequest(1);
    UserDialog userDialog = await dialog;
    DialogText firstText = userDialog.firstDialog;
    setState(() {
      currentDialog = firstText;
    });
  }

  void loadTimer() {
    _timer = new Timer(Duration(seconds: 60), () {
      print("Time's up !");
      if (!isRecordPlaying && _tabController.index == 0) {
//        _speak('どうした？助けが必要ですか？');
      }
    });
  }

  void reloadTimer() {
    _timer.cancel();
    loadTimer();
  }

  initializeTts() {
    _flutterTts = FlutterTts();
    setTtsLanguage('ja-JP');

    _flutterTts.setStartHandler(() {
      print('started');
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    _flutterTts.setCompletionHandler(() {
      print('completion !');
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setErrorHandler((err) {
      setState(() {
        print("error occurred: " + err);
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _speak(String text) async {
    print('here speak $text');
    await setTtsLanguage('ja-JP');
    if (text != null && text.isNotEmpty) {
      var result = await _flutterTts.speak(text);
      if (result == 1) setState(() => ttsState = TtsState.playing);
    }
  }

  Future<void> setTtsLanguage(String languageCode) async {
    await _flutterTts.setLanguage(languageCode);
  }

  Future _stop() async {
    var result = await _flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  //TODO
  DialogText _getNextQuestion(DialogText lastAnswer) {
    List<DialogText> possibleNextQuestions = lastAnswer.possibleAnswers;
    if (possibleNextQuestions.length == 1) {
      return lastAnswer.possibleAnswers[0];
    } else if (possibleNextQuestions.length > 1) {
      int randomIndex = generateRandomIndex(possibleNextQuestions);
      return lastAnswer.possibleAnswers[randomIndex];
    } else {
      return null;
    }
  }

  void _goToNextQuestionOrEnd(DialogText answer) {
    isAnswerSelected = false;
    DialogText nextQuestion = _getNextQuestion(answer);
    if (nextQuestion != null) {
      currentDialog = nextQuestion;
      _speak(nextQuestion.text);
    } else {
      Navigator.of(context).pushNamed(DeckHomePage.routeName);
    }
  }

  Widget _renderListeningTab() {
    if (isDialogStarted) {
      return Container(
          color: Color(COLOR_GREY),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: currentDialog.possibleAnswers.length,
                  itemBuilder: (BuildContext context, int index) {
                    DialogText answer = currentDialog.possibleAnswers[index];
                    return GestureDetector(
                      onTap: () async {
                        if (!isAnswerSelected) {
                          selectedAnswer = answer;
                          isAnswerSelected = true;
                          await _speak(answer.text);
                        } else {
                          _goToNextQuestionOrEnd(answer);
                        }
                        setState(() {});
                      },
                      child: ListTile(
                        title: Center(
                          child: Text("${answer.text}",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400)),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey,
                  ),
                ),
              ),
              Visibility(
                visible: isAnswerSelected,
                child: GestureDetector(
                  onTap: () {
                    _goToNextQuestionOrEnd(selectedAnswer);
                    setState(() {});
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: double.infinity,
                    color: Color(COLOR_ORANGE),
                    child: Center(
                        child: Text(
                      LocalizationWidget.of(context)
                          .getLocalizeValue('next')
                          .toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
                  ),
                ),
              )
            ],
          ));
    }
    return _renderStartDialog();
  }

  Widget _renderStartDialog() {
    return Container(
      color: Color(COLOR_GREY),
      child: Center(
        child: RaisedButton(
            onPressed: () {
              if (currentDialog != null && currentDialog.text.isNotEmpty) {
                isDialogStarted = true;
                _speak(currentDialog.text);
                loadTimer();
              }
            },
            child: Text(
                LocalizationWidget.of(context).getLocalizeValue('start_conv'))),
      ),
    );
  }

  String _renderReadingInstruction() {
    if (isAnswerSelected) {
      return 'Translate into japanese: ' + '"${selectedAnswer.translation}"';
    }
    return 'Choose an answer to write in japanese';
  }

  Widget _renderPossibleAnswersOrInput() {
    if (isAnswerSelected) {
      return Padding(
        padding: const EdgeInsets.only(left: 30.0, right: 30),
        child: TextFormField(
          controller: _answerInputController,
          validator: (value) {
            if (value.isEmpty) {
              return LocalizationWidget.of(context)
                  .getLocalizeValue('field_empty');
            }
            if (value.trim() != selectedAnswer.text.trim()){
              _answerInputController.text = selectedAnswer.text;
              return LocalizationWidget.of(context).getLocalizeValue('wrong_translation') + selectedAnswer.text;
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: '答え',
            labelStyle: TextStyle(),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: currentDialog.possibleAnswers.length,
      itemBuilder: (BuildContext context, int index) {
        DialogText answer = currentDialog.possibleAnswers[index];
        return GestureDetector(
          onTap: () async {
            if (!isAnswerSelected) {
              selectedAnswer = answer;
              isAnswerSelected = true;
            } else {
              _goToNextQuestionOrEnd(answer);
            }
            setState(() {});
          },
          child: ListTile(
            title: Center(
              child: Text("${answer.translation}",
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey,
      ),
    );
  }

  Widget _renderReadingTab() {
    if (isDialogStarted) {
      return Container(
          color: Color(COLOR_GREY),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(

                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Question',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currentDialog.text,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _renderReadingInstruction(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: _renderPossibleAnswersOrInput(),
                  ),
                  Visibility(
                    visible: isAnswerSelected,
                    child: GestureDetector(
                      onTap: () {
                        if (_formKey.currentState.validate()) {
                          _answerInputController.clear();
                          _goToNextQuestionOrEnd(selectedAnswer);
                          setState(() {});
                        }
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: double.infinity,
                        color: Color(COLOR_ORANGE),
                        child: Center(
                            child: Text(
                          LocalizationWidget.of(context)
                              .getLocalizeValue('next')
                              .toUpperCase(),
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ));
    }
    return _renderStartDialog();
  }

  Widget _renderTabs() {
    return (Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
            child: GestureDetector(
          onTap: () {
            setState(() {
              isListening = true;
              _tabController.index = 0;
            });
          },
          child: Container(
              color: isListening ? Colors.white : Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(
                  LocalizationWidget.of(context)
                      .getLocalizeValue('listening')
                      .toUpperCase(),
                  style: TextStyle(
                    color: isListening ? Colors.black : Colors.white,
                  ),
                )),
              )),
        )),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isListening = false;
                _tabController.index = 1;
              });
            },
            child: Container(
                color: isListening ? Colors.black : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                          LocalizationWidget.of(context)
                              .getLocalizeValue('reading')
                              .toUpperCase(),
                          style: TextStyle(
                            color: isListening ? Colors.white : Colors.black,
                          ))),
                )),
          ),
        )
      ],
    ));
  }

//  Color getColorDependingOnBackground() async{
//    PaletteGenerator paletteGenerator =
//        await PaletteGenerator.fromImage();
//  }

  Widget _renderContextImg() {
    //https://stackoverflow.com/questions/48750361/flutter-detect-keyboard-open-close
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    if (isKeyboardVisible) {
      return Container();
    }
    return Expanded(
      flex: 3,
      child: Stack(
        children: <Widget>[
          Container(
            child: Center(
              child: Image.asset(
                'lib/imgs/app_icon.png',
                height: MediaQuery.of(context).size.width * 0.45,
              ),
            ),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("lib/imgs/japan.png"),
                    fit: BoxFit.cover)),
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  if (!isRecordPlaying && currentDialog.text.isNotEmpty) {
                    _speak(currentDialog.text);
                  } else {
                    _stop();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.loop,
                    size: 40,
                  ),
                ),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
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
          future: dialog,
          builder: (BuildContext context, AsyncSnapshot dialogSnapshot) {
            switch (dialogSnapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: Text(LocalizationWidget.of(context)
                      .getLocalizeValue('loading')),
                );
              case ConnectionState.done:
                return Column(
                  children: <Widget>[
                    _renderContextImg(),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      child: _renderTabs(),
                    ),
                    Expanded(
                      flex: 5,
                      child: TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          _renderListeningTab(),
                          _renderReadingTab(),
                        ],
                      ),
                    )
                  ],
                );
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
