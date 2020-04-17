import 'Answer.dart';

class DeckCard {
  int id;
  List<Answer> answers;
  String question;
  String hint;
  int languageCode;
  int answerLanguageCode;
  bool isReversible;

  DeckCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        answers = decodeAnswerJsonArray(json['answers']),
        question = json['question'],
        hint = json['hint'],
        languageCode = json['languageCode'],
        answerLanguageCode = json['answerLanguageCode'],
        isReversible = json['isReversible'] == 'true'
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