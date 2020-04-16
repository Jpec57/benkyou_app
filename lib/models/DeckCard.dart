import 'Answer.dart';

class DeckCard {
  int id;
  List<Answer> answers;

  DeckCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        answers = decodeAnswerJsonArray(json['answers'])
  ;
}

List<DeckCard> decodeDeckCardJsonArray(array){
  if (array == null){
    return [];
  }
  List<DeckCard> cards = [];
  for (var card in array){
    cards.add(DeckCard.fromJson(card));
  }
  return cards;
}