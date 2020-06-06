import 'package:benkyou/models/Sentence.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped }

class ThemeListeningPlayerWidget extends StatefulWidget{
  final Sentence sentence;

  const ThemeListeningPlayerWidget({Key key, this.sentence}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeListeningPlayerWidgetState();
}

class ThemeListeningPlayerWidgetState extends State<ThemeListeningPlayerWidget>{
  double _textSpeed = 1;
  int _remainingListening;
  FlutterTts _flutterTts;
  bool isRecordPlaying = false;
  TtsState ttsState = TtsState.stopped;
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;

  @override
  void initState() {
    super.initState();
    _remainingListening = 4;
    initializeTts();
  }

  @override
  void didUpdateWidget(ThemeListeningPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _remainingListening = 4;
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
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
    if (_remainingListening > 0){
      _remainingListening--;
      await setTtsLanguage('ja-JP');
      if (text != null && text.isNotEmpty) {
        var result = await _flutterTts.speak(text);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  Future<void> setTtsLanguage(String languageCode) async {
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.setSpeechRate(_textSpeed);
  }

  Future _stop() async {
    var result = await _flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: Container(
            decoration: BoxDecoration(
              color: Color(COLOR_ORANGE),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 2.0,
                  spreadRadius: 0.0,
                  offset: Offset(2.0, 2.0), // shadow direction: bottom right
                )
              ],
            ),
            height: MediaQuery.of(context).size.width * 0.35,
            child: Stack(children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("$_remainingListening", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                      Text(LocalizationWidget.of(context).getLocalizeValue('remaining'))
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (!isRecordPlaying && widget.sentence.text.isNotEmpty) {
                    _speak(widget.sentence.text);
                  } else {
                    _stop();
                  }
                },
                child: Center(
                  child: Icon(
                      isPlaying
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      size: 50),
                ),
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 30,
                      width: 150,
                      child: Slider(
                        activeColor: Colors.black,
                        value: _textSpeed,
                        min: 0.5,
                        max: 1.0,
                        onChanged: (newSpeed) {
                          setState(() {
                            _textSpeed = newSpeed;
                          });
                        },
                      ),
                    ),
                  )),
            ]),
          ),
        ),
      ),
    );
  }

}