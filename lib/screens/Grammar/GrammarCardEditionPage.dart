import 'package:benkyou/models/GrammarPointCard.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/material.dart';

class GrammarCardEditionPage extends StatefulWidget {
  static const routeName = '/grammar-card/edit';
  final int cardId;

  const GrammarCardEditionPage({Key key, @required this.cardId})
      : super(key: key);

  @override
  _GrammarCardEditionPageState createState() => _GrammarCardEditionPageState();
}

class _GrammarCardEditionPageState extends State<GrammarCardEditionPage> {
  Future<GrammarPointCard> _grammarCard;

  @override
  void initState() {
    super.initState();
    _grammarCard = getUserGrammarCard(widget.cardId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("id ${widget.cardId}");
    return Scaffold(
      drawer: MainDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 200,
              color: Colors.red,
              width: MediaQuery.of(context).size.width,
            ),
            Expanded(
                child: FutureBuilder(
              future: _grammarCard,
              builder: (BuildContext context,
                  AsyncSnapshot<GrammarPointCard> cardSnap) {
                switch (cardSnap.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.done:
                    if (!cardSnap.hasData) {
                      return Container();
                    }
                    print(cardSnap.data);
                    return Text("victory");
                  case ConnectionState.none:
                    return Center(
                        child: Text(LocalizationWidget.of(context)
                            .getLocalizeValue('no_internet_connection')));
                  default:
                    return Center(
                        child: Text(LocalizationWidget.of(context)
                            .getLocalizeValue('empty')));
                }
              },
            ))
          ],
        ),
      ),
    );
  }
}
