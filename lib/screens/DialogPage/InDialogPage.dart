import 'dart:async';
import 'dart:ui';

import 'package:benkyou/models/DialogText.dart';
import 'package:benkyou/models/UserDialog.dart';
import 'package:benkyou/services/api/dialogRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/utils/random.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:palette_generator/palette_generator.dart';

class InDialogPage extends StatefulWidget {
  static const routeName = '/dialog/in';

  @override
  State<StatefulWidget> createState() => InDialogPageState();
}

class InDialogPageState extends State<InDialogPage> with SingleTickerProviderStateMixin{
  TabController _tabController;
  bool isDialogStarted = false;
  Future<UserDialog> dialog;
  FlutterTts _flutterTts;
  bool isRecordPlaying = false;
  bool isListening = true;
  DialogText currentDialog;
//  String currentQuestion;
//  List<DialogText> currentPossibleAnswers;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _initDialog();
    initializeTts();
    _tabController = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _flutterTts.stop();
    _tabController.dispose();
  }

  void _initDialog() async{
    dialog = getDialogRequest(1);
    UserDialog userDialog = await dialog;
    DialogText firstText = userDialog.firstDialog;
    setState(() {
      currentDialog = firstText;
    });
  }

  void loadTimer(){
    _timer = new Timer(Duration(seconds: 60), (){
      print("Time's up !");
      if (!isRecordPlaying && _tabController.index == 0){
//        _speak('どうした？助けが必要ですか？');
      }
    });
  }

  void reloadTimer(){
    _timer.cancel();
    loadTimer();
  }

  initializeTts() {
    _flutterTts = FlutterTts();
    setTtsLanguage('ja-JP');

    _flutterTts.setStartHandler(() {
      setState(() {
        isRecordPlaying = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        isRecordPlaying = false;
      });
    });

    _flutterTts.setErrorHandler((err) {
      setState(() {
        print("error occurred: " + err);
        isRecordPlaying = false;
      });
    });
  }

  Future _speak(String text) async {
    print('here speak $text');
    await setTtsLanguage('ja-JP');
    if (text != null && text.isNotEmpty) {
      var result = await _flutterTts.speak(text);
      print(result);
      if (result == 1)
        setState(() {
          isRecordPlaying = true;
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
        isRecordPlaying = false;
      });
  }

  //TODO
  DialogText _getNextQuestion(DialogText lastAnswer) {
    List<DialogText> possibleNextQuestions = lastAnswer.possibleAnswers;
    if (possibleNextQuestions.length == 1){
      return lastAnswer.possibleAnswers[0];
    } else if (possibleNextQuestions.length > 1){
      int randomIndex = generateRandomIndex(possibleNextQuestions);
      return lastAnswer.possibleAnswers[randomIndex];
    } else {
      return null;
    }
  }

  Widget _renderListeningTab(){
    if (isDialogStarted){
      return Container(
        color: Color(COLOR_GREY),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: currentDialog.possibleAnswers.length,
          itemBuilder: (BuildContext context, int index) {
            DialogText answer = currentDialog.possibleAnswers[index];
            return GestureDetector(
              onTap: () async {
                await _speak(answer.text).whenComplete((){
                });

                DialogText nextQuestion = _getNextQuestion(answer);
                if (nextQuestion != null){
                  currentDialog = nextQuestion;
                  _speak(nextQuestion.text);
                }
                setState(() {
                });
              },
              child: ListTile(
                title: Center(
                  child: Text("${answer.text}",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey,
          ),
        )
      );
    }
    return Container(
      color: Color(COLOR_GREY),
      child: Center(
        child: RaisedButton(
            onPressed: (){
              if (currentDialog != null && currentDialog.text.isNotEmpty){
                isDialogStarted = true;
                _speak(currentDialog.text);
                loadTimer();
              }
            },
            child: Text(LocalizationWidget.of(context).getLocalizeValue('start_conv'))
        ),
      ),
    );
  }

  Widget _renderReadingTab(){
    return Container(
      color: Color(COLOR_ORANGE),
      child: Center(
        child: RaisedButton(
            onPressed: (){
              if (currentDialog != null && currentDialog.text.isNotEmpty){
                _speak(currentDialog.text);
              }
            },
            child: Text('Lol')
        ),
      ),
    );
  }

  Widget _renderTabs(){
    return (
      Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
              child: GestureDetector(
                onTap: (){
                  setState(() {
                    isListening = true;
                    _tabController.index = 0;
                  });
                },
                child: Container(
                    color:
                    isListening ? Colors.white : Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(LocalizationWidget.of(context).getLocalizeValue('listening').toUpperCase(), style: TextStyle(color: isListening ? Colors.black : Colors.white,),)),
                    )),
              )),
          Expanded(
            child: GestureDetector(
              onTap: (){
                setState(() {
                  isListening = false;
                  _tabController.index = 1;
                });
              },
              child: Container(
                  color:
                  isListening ? Colors.black : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('reading').toUpperCase(), style: TextStyle(color: isListening ? Colors.white : Colors.black,))),
                  )),
            ),
          )
        ],
      )
    );
  }



//  Color getColorDependingOnBackground() async{
//    PaletteGenerator paletteGenerator =
//        await PaletteGenerator.fromImage();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text(LocalizationWidget.of(context).getLocalizeValue('dialog')),
      ),
      body: FutureBuilder(
        future: dialog,
        builder: (BuildContext context, AsyncSnapshot dialogSnapshot) {
          switch (dialogSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: Text(LocalizationWidget.of(context).getLocalizeValue('loading')),
              );
            case ConnectionState.done:
              return Column(
                children: <Widget>[
                  Expanded(
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
                              onTap: (){
                                if (!isRecordPlaying&& currentDialog.text.isNotEmpty){
                                  _speak(currentDialog.text);
                                } else{
                                  _stop();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.loop, size: 40,),
                              ),
                            ))
                      ],
                    ),
                  ),
                  Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
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
                child: Text(LocalizationWidget.of(context).getLocalizeValue('empty')),
              );
          }
        },
      ),
    );
  }
}
