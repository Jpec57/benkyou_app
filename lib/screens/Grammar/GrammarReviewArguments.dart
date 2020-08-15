import 'package:benkyou/models/UserCard.dart';
import 'package:flutter/cupertino.dart';

class GrammarReviewArguments {
  List<UserCard> reviewCards;
  int deckId;
  bool isFromHomePage;

  GrammarReviewArguments(
      {@required this.reviewCards, this.deckId, this.isFromHomePage = false});
}
