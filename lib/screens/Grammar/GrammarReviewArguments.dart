import 'package:benkyou/models/UserCard.dart';
import 'package:flutter/cupertino.dart';

class GrammarReviewArguments {
  List<UserCard> reviewCards;
  int deckId;

  GrammarReviewArguments({@required this.reviewCards, @required this.deckId});
}
