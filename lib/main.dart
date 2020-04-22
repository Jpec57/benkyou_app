import 'package:benkyou_app/screens/BrowseDeckPage/BrowseDeckPage.dart';
import 'package:benkyou_app/screens/CreateCardPage/CreateCardPage.dart';
import 'package:benkyou_app/screens/CreateCardPage/CreateCardPageArguments.dart';
import 'package:benkyou_app/screens/CreateUserPage/CreateUserPage.dart';
import 'package:benkyou_app/screens/ListCardPage/ListCardPage.dart';
import 'package:benkyou_app/screens/ListCardPage/ListCardPageArguments.dart';
import 'package:benkyou_app/screens/PreviewPublicDeckPage/PreviewPublicDeckPage.dart';
import 'package:benkyou_app/screens/PreviewPublicDeckPage/PreviewPublicDeckPageArguments.dart';
import 'package:benkyou_app/screens/ReviewPage/ReviewPage.dart';
import 'package:benkyou_app/screens/ReviewPage/ReviewPageArguments.dart';
import 'package:benkyou_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/DeckPage/DeckPage.dart';
import 'screens/DeckPage/DeckPageArguments.dart';
import 'screens/HomePage/HomePage.dart';

void main() => runApp(MaterialApp(
  title: 'Benkyou',
  navigatorKey: Get.key,
  theme: ThemeData(
    primaryColor: Color(COLOR_DARK_BLUE),
  ),
  initialRoute: HomePage.routeName,
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

    if (settings.name == ListCardPage.routeName){
      final ListCardPageArguments args = settings.arguments;
      return MaterialPageRoute(
        builder: (context) {
          return ListCardPage(
            deckId: args.deckId,
          );
        },
      );
    }

    if (settings.name == PreviewPublicDeckPage.routeName){
      final PreviewPublicDeckPageArguments args = settings.arguments;
      return MaterialPageRoute(
        builder: (context) {
          return PreviewPublicDeckPage(
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
    CreateUserPage.routeName: (context) => CreateUserPage(),
    BrowseDeckPage.routeName: (context) => BrowseDeckPage(),
  },
));
