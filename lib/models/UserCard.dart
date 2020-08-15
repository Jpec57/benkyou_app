import 'package:benkyou/models/DeckCard.dart';
import 'package:benkyou/models/GrammarPointCard.dart';

import 'Answer.dart';
import 'Deck.dart';

class UserCard {
  int id;
  DeckCard card;
  GrammarPointCard grammarCard;
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
        grammarCard = json['card'].containsKey('gapSentences')
            ? GrammarPointCard.fromJson(json['card'])
            : null,
        userAnswers = decodeAnswerJsonArray(json['userAnswers']);

  UserCard.fromId(Map<String, dynamic> json) : id = json['id'];

  @override
  String toString() {
    return 'UserCard{id: $id, card: $card, grammarCard: $grammarCard, deck: $deck, nbErrors: $nbErrors, nbSuccess: $nbSuccess, nextAvailable: $nextAvailable, userNote: $userNote, userAnswers: $userAnswers, lvl: $lvl}';
  }

  List<String> getAllAnswersAsString() {
    List<String> stringAnswers = [];
    for (Answer answer in userAnswers) {
      stringAnswers.add(answer.text);
    }
    for (Answer answer in card.answers) {
      stringAnswers.add(answer.text);
    }
    return stringAnswers;
  }
}

List<UserCard> decodeUserCardJsonArray(array) {
  if (array == null) {
    return [];
  }
  List<UserCard> cards = [];
  for (var card in array) {
    try {
      var test = UserCard.fromJson(card);
      cards.add(test);
    } catch (e) {}
  }
  return cards;
}
