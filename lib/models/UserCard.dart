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

  UserCard.fromId(Map<String, dynamic> json)
      : id = json['id']
  ;

  @override
  String toString() {
    return 'UserCard{id: $id, card: $card, deck: $deck, nbErrors: $nbErrors, nbSuccess: $nbSuccess, nextAvailable: $nextAvailable, userNote: $userNote, userAnswers: $userAnswers, lvl: $lvl}';
  }

  List<String> getAllAnswersAsString(){
    List<String> stringAnswers = [];
    for (Answer answer in userAnswers){
      stringAnswers.add(answer.text);
    }
    for (Answer answer in card.answers){
      stringAnswers.add(answer.text);
    }
    return stringAnswers;
  }


}

List<UserCard> decodeUserCardJsonArray(array){
  if (array == null){
    return [];
  }
  List<UserCard> cards = [];
  for (var card in array){
    try {
      var test = UserCard.fromJson(card);
      print("test $test");
      cards.add(test);
    }catch(e){

    }

  }
  print("END");
  return cards;
}