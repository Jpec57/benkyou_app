import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/Deck.dart';
import '../DeckPage/DeckPage.dart';
import '../DeckPage/DeckPageArguments.dart';

class DeckContainer extends StatelessWidget{
  final Deck deck;

  const DeckContainer({Key key, @required this.deck}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.pushReplacementNamed(
          context,
          DeckPage.routeName,
          arguments: DeckPageArguments(
              deck.id
          ),
        );
//        Navigator.pushNamed(
//          context,
//          DeckPage.routeName,
//          arguments: DeckPageArguments(
//              deck.id
//          ),
//        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.orange
        ),
        child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                deck.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                ),
              ),
            )
        ),
      ),
    );
  }

}