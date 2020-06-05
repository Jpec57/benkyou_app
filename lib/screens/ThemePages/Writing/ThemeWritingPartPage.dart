import 'package:benkyou/models/DeckTheme.dart';
import 'package:benkyou/models/Sentence.dart';
import 'package:benkyou/services/api/sentenceRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/ThemeTransitionDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeWritingPartPage extends StatefulWidget{
  static const routeName = '/themes/writing';
  final DeckTheme theme;

  const ThemeWritingPartPage({Key key, @required this.theme}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeWritingPartPageState();

}

class ThemeWritingPartPageState extends State<ThemeWritingPartPage> {
  Future<List<Sentence>> _sentences;

  @override
  void initState() {
    super.initState();
    _sentences = getRandomThemeSentencesRequest(widget.theme.id, 2);
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      showDialog(context: context, builder: (BuildContext context) => ThemeTransitionDialog(name: 'Writing expression'));
      Future.delayed(Duration(seconds: 3), (){
        Navigator.of(context).pop();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _renderWritingPart(List<Sentence> sentences){
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Color(COLOR_ORANGE),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(LocalizationWidget.of(context).getLocalizeValue('translate'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 26),),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Center(child: Text('ici', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.green,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _sentences,
        builder: (BuildContext context, AsyncSnapshot<dynamic> sentenceSnap) {
        switch (sentenceSnap.connectionState){
          case ConnectionState.done:
            List<Sentence> sentences = sentenceSnap.data;
            return _renderWritingPart(sentences);
          case ConnectionState.waiting:
            return Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('loading')),);
          default:
            return Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('loading')),);
        }
      },),
    );
  }
}