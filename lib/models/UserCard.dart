import 'package:benkyou/models/DeckCard.dart';

import 'Answer.dart';
import 'Deck.dart';

class UserCard {
  int id;
  DeckCard card;
  Deck deck;
  int nbErrors;
  int nbSuccess;
  String nextAvailable;
  String userNote;
  List<Answer> userAnswers;
  int lvl;

  UserCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        lvl = json['level'],
        userNote = json['userNote'],
        nextAvailable = json['nextAvailable'],
        nbSuccess = json['nbSuccess'],
        nbErrors = json['nbErrors'],
        deck = Deck.fromJson(json['deck']),
        card = DeckCard.fromJson(json['card']),
        userAnswers = decodeAnswerJsonArray(json['userAnswers'])
  ;

  @override
  String toString() {
    return 'UserCard{id: $id, card: $card, deck: $deck, nbErrors: $nbErrors, nbSuccess: $nbSuccess, nextAvailable: $nextAvailable, userNote: $userNote, userAnswers: $userAnswers, lvl: $lvl}';
  }


}

List<UserCard> decodeUserCardJsonArray(array){
  if (array == null){
    return [];
  }
  List<UserCard> cards = [];
  for (var card in array){
    cards.add(UserCard.fromJson(card));
  }
  return cards;
}