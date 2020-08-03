import 'package:benkyou/models/Deck.dart';
import 'package:benkyou/screens/GrammarReviewPage/GrammarHomeHeaderClipper.dart';
import 'package:benkyou/services/api/deckRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/material.dart';

class GrammarHomePage extends StatefulWidget {
  static const String routeName = '/grammar/home';

  @override
  _GrammarHomePageState createState() => _GrammarHomePageState();
}

class _GrammarHomePageState extends State<GrammarHomePage> {
  Future<List<Deck>> _grammarDecks;

  @override
  void initState() {
    super.initState();
    _grammarDecks = getGrammarDecks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;

    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Grammar'),
        elevation: 0,
      ),
      body: SafeArea(
          child: Column(
        children: [
          Container(
            child: ClipPath(
              clipper: GrammarHomeHeaderClipper(),
              child: Container(
                color: Color(COLOR_DARK_BLUE),
                height: phoneSize.height * 0.1,
                child: Align(
                  child: Text(
                    "All review",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  alignment: FractionalOffset(0.5, 0.2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 10, left: 10),
            child: FutureBuilder(
              future: _grammarDecks,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Deck>> deckSnapshot) {
                switch (deckSnapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.done:
                    if (deckSnapshot.hasData) {
                      return ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {},
                              title: Text("Je suis une tile"),
                            );
                          },
                          separatorBuilder: (context, index) => Divider(
                                color: Colors.black,
                              ),
                          itemCount: deckSnapshot.data.length);
                    }
                    return Center(
                        child: Text(LocalizationWidget.of(context)
                            .getLocalizeValue('empty')));
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
            ),
          ),
        ],
      )),
    );
  }
}
