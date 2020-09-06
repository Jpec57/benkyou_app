import 'package:benkyou/screens/BrowseDeckPage/BrowseDeckPage.dart';
import 'package:benkyou/screens/Grammar/GrammarCardListPage.dart';
import 'package:benkyou/screens/Grammar/GrammarHomePage.dart';
import 'package:benkyou/screens/HomePage/HomePage.dart';
import 'package:benkyou/screens/LessonHomePage/LessonHomePage.dart';
import 'package:benkyou/screens/ListCardPage/ListCardPage.dart';
import 'package:benkyou/screens/ListCardPage/ListCardPageArguments.dart';
import 'package:benkyou/screens/ListDialogs/ListDialogPage.dart';
import 'package:benkyou/screens/ProfilePage/ProfilePage.dart';
import 'package:benkyou/screens/ThemePages/ThemeLearningHomePage.dart';
import 'package:benkyou/services/api/userRequests.dart';
import 'package:benkyou/widgets/LoadingCircle.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/LoginDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/DeckHomePage/DeckHomePage.dart';

class MainDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainDrawerState();
}

class MainDrawerState extends State<MainDrawer> {
  Future<bool> isUserConnected;

  @override
  void initState() {
    super.initState();
    isUserConnected = _isUserConnected();
  }

  Future<bool> _isUserConnected() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userId = sharedPreferences.getInt('userId');
    return userId != null;
  }

  Widget _renderLoginTile() {
    return FutureBuilder(
        future: isUserConnected,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return ListTile(
                title: Text(
                    LocalizationWidget.of(context).getLocalizeValue('loading')),
              );
            case ConnectionState.done:
              if (snapshot.hasData && snapshot.data) {
                return ListTile(
                  title: Text(LocalizationWidget.of(context)
                      .getLocalizeValue('log_out')),
                  onTap: () async {
                    showLoadingDialog(context);
                    await logoutRequest();
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      DeckHomePage.routeName,
                    );
                  },
                );
              }
              return ListTile(
                title: Text(
                    LocalizationWidget.of(context).getLocalizeValue('log_in')),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => LoginDialog());
                },
              );
            default:
              return ListTile(
                title: Text(
                    LocalizationWidget.of(context).getLocalizeValue('log_in')),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => LoginDialog());
                  // Update the state of the app.
                  // ...
                },
              );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Align(
                alignment: Alignment.bottomLeft,
                child: FutureBuilder(
                  future: isUserConnected,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.done:
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data ? '今日は！' : 'ようこそ!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 3.0,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          );
                        }
                        return Text(
                          'ようこそ!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        );
                      default:
                        return Text(
                          'ようこそ!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        );
                    }
                  },
                )),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("lib/imgs/japan.png"),
                    fit: BoxFit.cover)),
          ),
          ListTile(
            title:
                Text(LocalizationWidget.of(context).getLocalizeValue('home')),
            onTap: () {
              Navigator.pushNamed(
                context,
                HomePage.routeName,
              );
            },
          ),
          ListTile(
            title: Text(
                LocalizationWidget.of(context).getLocalizeValue('my_profile')),
            onTap: () {
              Navigator.pushNamed(
                context,
                ProfilePage.routeName,
              );
            },
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 8.0),
              child: Text(
                'Review',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
          ),
          ListTile(
            title: Text(LocalizationWidget.of(context)
                .getLocalizeValue('my_word_decks')),
            onTap: () {
              Navigator.pushNamed(
                context,
                DeckHomePage.routeName,
              );
            },
          ),
          ListTile(
            title: Text(LocalizationWidget.of(context)
                .getLocalizeValue('my_grammar_decks')),
            onTap: () {
              Navigator.pushNamed(
                context,
                GrammarHomePage.routeName,
              );
            },
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 8.0),
              child: Text(
                'Learn',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
          ),
          ListTile(
            title: Text(
                LocalizationWidget.of(context).getLocalizeValue('lessons')),
            onTap: () {
              Navigator.pushNamed(
                context,
                LessonHomePage.routeName,
              );
            },
          ),
          ListTile(
            title:
                Text(LocalizationWidget.of(context).getLocalizeValue('themes')),
            onTap: () {
              Navigator.pushNamed(
                context,
                ThemeLearningHomePage.routeName,
              );
            },
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 8.0),
              child: Text(
                'Discover',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
          ),
          ListTile(
            title: Text(LocalizationWidget.of(context)
                .getLocalizeValue('browse_online_decks')),
            onTap: () {
              Navigator.pushNamed(
                context,
                BrowseDeckPage.routeName,
              );
            },
          ),
          ListTile(
            title: Text(
                LocalizationWidget.of(context).getLocalizeValue('dialogs')),
            onTap: () {
              Navigator.pushNamed(
                context,
                ListDialogPage.routeName,
              );
            },
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 8.0),
              child: Text(
                LocalizationWidget.of(context).getLocalizeValue('my_cards'),
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
          ),
          ListTile(
            title: Text(LocalizationWidget.of(context)
                .getLocalizeValue('my_word_cards')),
            onTap: () {
              Navigator.pushNamed(context, ListCardPage.routeName,
                  arguments: ListCardPageArguments());
            },
          ),
          ListTile(
            title: Text(LocalizationWidget.of(context)
                .getLocalizeValue('my_grammar_cards')),
            onTap: () {
              Navigator.pushNamed(context, GrammarCardListPage.routeName);
            },
          ),
          _renderLoginTile(),
        ],
      ),
    );
  }
}
