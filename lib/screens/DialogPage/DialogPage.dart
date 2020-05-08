import 'package:benkyou/services/rest.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';

class DialogPage extends StatefulWidget {
  static const routeName = '/dialog';

  @override
  State<StatefulWidget> createState() => DialogPageState();
}

class DialogPageState extends State<DialogPage> {
  static const text = 'これは私の弟です';
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  String resultText = "";

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() => resultText = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Dialog'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              if (_isAvailable && !_isListening) {
                _speechRecognition
                    .listen(locale: "en_US")
                    .then((result) => print('$result'));
              }
            },
            child: Container(
              color: Colors.red,
              height: 300,
              child: Text(
                LocalizationWidget.of(context).getLocalizeValue('start'),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (_isAvailable && !_isListening) {
                if (_isListening)
                  _speechRecognition.cancel().then(
                        (result) => setState(() {
                          _isListening = result;
                          resultText = "";
                        }),
                      );
              }
            },
            child: Container(
              color: Colors.blue,
              height: 100,
              child: Text(
                LocalizationWidget.of(context).getLocalizeValue('stop'),
              ),
            ),
          ),
          Container(
            color: Colors.green,
            height: 100,
            child: Text(
              resultText,
              style: TextStyle(fontSize: 24.0),
            ),
          ),
        ],
      ),
    );
  }
}
