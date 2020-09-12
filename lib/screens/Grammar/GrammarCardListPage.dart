import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/screens/Grammar/GrammarCardEditionPage.dart';
import 'package:benkyou/screens/Grammar/GrammarCardEditionPageArguments.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/GrammarPointWidget.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/material.dart';

import 'GrammarHomeHeaderClipper.dart';

class GrammarCardListPage extends StatefulWidget {
  static const routeName = '/grammar-card/list';

  @override
  _GrammarCardListPageState createState() => _GrammarCardListPageState();
}

class _GrammarCardListPageState extends State<GrammarCardListPage> {
  TextEditingController _searchController;
  Future<List<UserCard>> _grammarCards;

  @override
  void initState() {
    super.initState();
    _searchController = new TextEditingController();
    _grammarCards = getUserGrammarCards();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;

    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Grammar card list'),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              ClipPath(
                clipper: GrammarHomeHeaderClipper(),
                child: Container(
                  color: Color(COLOR_DARK_BLUE),
                  height: phoneSize.height * 0.15,
                  child: Align(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.search),
                          ),
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12)),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.all(5)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    alignment: FractionalOffset(0.5, 0),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: _grammarCards,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<UserCard>> cardSnap) {
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
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: ListView.separated(
                              itemBuilder: (BuildContext context, int index) {
                                return GrammarPointCardWidget(
                                  card: cardSnap.data[index].card,
                                  grammarCard: cardSnap.data[index].grammarCard,
                                  onClick: () {
                                    print("Je suis cliqué");
                                    Navigator.of(context).pushNamed(
                                        GrammarCardEditionPage.routeName,
                                        arguments:
                                            GrammarCardEditionPageArguments(
                                                cardId: cardSnap
                                                    .data[index].card.id));
                                  },
                                );
                              },
                              separatorBuilder: (context, index) => Divider(
                                    color: Colors.grey,
                                  ),
                              itemCount: cardSnap.data.length),
                        );
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
              )
//            _renderGrammarPoint()
            ],
          ),
        ),
      ),
    );
  }
}
