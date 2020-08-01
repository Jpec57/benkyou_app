import 'package:benkyou/models/Sentence.dart';
import 'package:benkyou/services/api/sentenceRequests.dart';
import 'package:flutter/material.dart';

import 'Localization.dart';

class SentenceSeekerWidget extends StatefulWidget {
  final String searchTerm;

  const SentenceSeekerWidget({Key key, this.searchTerm}) : super(key: key);

  @override
  _SentenceSeekerWidgetState createState() => _SentenceSeekerWidgetState();
}

class _SentenceSeekerWidgetState extends State<SentenceSeekerWidget> {
  Future<List<Sentence>> _sentences;

  @override
  void initState() {
    super.initState();
    _sentences = searchSentencesRequest("には", 3);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _sentences,
      builder: (BuildContext context, AsyncSnapshot<List<Sentence>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.done:
            if (snapshot.hasData) {
              return ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      color: Colors.grey,
                    );
                  },
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data[index].text),
                    );
                  });
            }
            return Container();
          case ConnectionState.none:
            return Center(
                child: Text(LocalizationWidget.of(context)
                    .getLocalizeValue('no_internet_connection')));
          default:
            return Center(
                child: Text(
                    LocalizationWidget.of(context).getLocalizeValue('empty')));
        }
      },
    );
  }
}
