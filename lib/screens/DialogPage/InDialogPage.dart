import 'dart:async';
import 'dart:ui';

import 'package:benkyou/models/DialogText.dart';
import 'package:benkyou/models/UserDialog.dart';
import 'package:benkyou/services/api/dialogRequests.dart';
import 'package:benkyou/utils/colors.dart';
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

class InDialogPageState extends State<InDialogPage> {
  bool isDialogStarted = false;
  Future<UserDialog> dialog;
  FlutterTts _flutterTts;
  bool isRecordPlaying = false;
  bool isListening = true;
  String currentQuestion;
  List<DialogText> currentPossibleAnswers;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _initDialog();
    initializeTts();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _flutterTts.stop();
  }

  void _initDialog() async{
    dialog = getDialogRequest(1);
    UserDialog userDialog = await dialog;
    DialogText firstText = userDialog.firstDialog;
    setState(() {
      currentQuestion = firstText.text;
      currentPossibleAnswers = firstText.possibleAnswers;
    });
  }

  void loadTimer(){
    _timer = new Timer(Duration(seconds: 30), (){
      print("Time's up !");
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

    _speak('tabetai');

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

  void _getNextQuestion() {}

//  Color getColorDependingOnBackground() async{
//    PaletteGenerator paletteGenerator =
//        await PaletteGenerator.fromImage();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Dialog'),
      ),
      body: FutureBuilder(
        future: dialog,
        builder: (BuildContext context, AsyncSnapshot dialogSnapshot) {
          switch (dialogSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: Text('Loading...'),
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
                                if (!isRecordPlaying){
                                  _speak(currentQuestion);
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
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  isListening = true;
                                });
                              },
                              child: Container(
                                  color:
                                      isListening ? Colors.white : Colors.black,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Text('Listening'.toUpperCase(), style: TextStyle(color: isListening ? Colors.black : Colors.white,),)),
                                  )),
                            )),
                        Expanded(
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                isListening = false;
                              });
                            },
                            child: Container(
                                  color:
                                      isListening ? Colors.black : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: Text('Reading'.toUpperCase(), style: TextStyle(color: isListening ? Colors.white : Colors.black,))),
                                  )),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Color(COLOR_GREY),
                      child: GestureDetector(
                        onTap: (){
                          if (currentQuestion != null && currentQuestion.isNotEmpty){
                            isDialogStarted = true;
                            _speak(currentQuestion);
                            loadTimer();
                          }
                        },
                        child: Center(
                          child: Text('Start conversation'),
                        ),
                      ),
                    ),
                  )
                ],
              );
            default:
              return Center(
                child: Text('Empty'),
              );
          }
        },
      ),
    );
  }
}
