import 'package:benkyou_app/screens/CreateCardPage/CreateCardPage.dart';
import 'package:benkyou_app/screens/CreateCardPage/CreateCardPageArguments.dart';
import 'package:benkyou_app/screens/ReviewPage/ReviewPage.dart';
import 'package:benkyou_app/screens/ReviewPage/ReviewPageArguments.dart';
import 'package:flutter/material.dart';
import 'screens/DeckPage/DeckPage.dart';
import 'screens/DeckPage/DeckPageArguments.dart';
import 'screens/HomePage/HomePage.dart';

void main() => runApp(MaterialApp(
  title: 'Benkyou',
  theme: ThemeData(
    primaryColor: Colors.orange,
  ),
  initialRoute: '/',
  onGenerateRoute: (settings){
    if (settings.name == DeckPage.routeName) {
      final DeckPageArguments args = settings.arguments;

      return MaterialPageRoute(
        builder: (context) {
          return DeckPage(
            id: args.id,
          );
        },
      );
    }
    if (settings.name == ReviewPage.routeName){
      final ReviewPageArguments args = settings.arguments;
      return MaterialPageRoute(
        builder: (context) {
          return ReviewPage(
            cards: args.cards,
          );
        },
      );
    }

    if (settings.name == CreateCardPage.routeName){
      final CreateCardPageArguments args = settings.arguments;
      return MaterialPageRoute(
        builder: (context) {
          return CreateCardPage(
            deckId: args.deckId,
          );
        },
      );
    }
    assert(false, 'Need to implement ${settings.name}');
    return null;
  },
  routes: {
    HomePage.routeName: (context) => HomePage(),
  },
));
