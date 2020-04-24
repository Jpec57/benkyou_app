import 'package:benkyou/models/UserCard.dart';
import 'package:flutter/material.dart';

class ReviewPageArguments {
  List<UserCard> cards;
  int deckId;

  ReviewPageArguments({@required this.cards, this.deckId});
}