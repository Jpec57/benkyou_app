import 'package:benkyou/models/JishoTranslation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Localization.dart';

class JishoList extends StatefulWidget {
  final String researchWord;
  final Function callback;

  const JishoList({Key key, this.researchWord, this.callback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => JishoListState();
}

class JishoListState extends State<JishoList> {

  String subtitleFormatter(JishoTranslation translation){
    String kanji = translation.kanji ?? '';
    String reading = translation.reading ?? '';
    if (kanji.isNotEmpty && reading.isNotEmpty){
      return '$kanji - $reading';
    }
    return '$kanji$reading';
  }

  Widget returnList(BuildContext context){
    if (widget.researchWord != null && widget.researchWord.isNotEmpty){
      return FutureBuilder(
          future: JishoTranslation.getJishoTransLationListFromRequest(widget.researchWord),
          builder: (BuildContext context, AsyncSnapshot<List<JishoTranslation>> snapshot){
            switch (snapshot.connectionState){
              case ConnectionState.done:
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index){
                        return Container(
                          child: (ListTile(
                            onTap: (){
                              widget.callback(snapshot.data[index]);
                            },
                            title: Center(child: Text(snapshot.data[index].english.join('; '))),
                            subtitle: Center(child: Text(subtitleFormatter(snapshot.data[index]))),
                          )),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              case ConnectionState.waiting:
                return Text(LocalizationWidget.of(context).getLocalizeValue('searching'));
              case ConnectionState.none:
                return Text(LocalizationWidget.of(context).getLocalizeValue('no_internet_connection'));
              default:
                return Text(LocalizationWidget.of(context).getLocalizeValue('empty'));
            }
          }
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        child: Text(LocalizationWidget.of(context).getLocalizeValue('kana_kanji_start_search'), style: TextStyle(fontStyle: FontStyle.italic)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return returnList(context);
  }
}