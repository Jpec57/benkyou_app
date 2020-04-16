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
    assert(false, 'Need to implement ${settings.name}');
    return null;
  },
  routes: {
    HomePage.routeName: (context) => HomePage(),
  },
));
