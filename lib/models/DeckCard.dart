import 'Answer.dart';

const LANGUAGE_CODE_ENGLISH = 0;
const LANGUAGE_CODE_JAPANESE = 1;

class DeckCard {
  int id;
  List<Answer> answers;
  String question;
  String hint;
  int languageCode;
  int answerLanguageCode;
  bool isReversible;
  int type;
  bool isActivated;

  DeckCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        answers = decodeAnswerJsonArray(json['answers']),
        question = json['question'],
        hint = json['hint'],
        type = json['type'],
        languageCode = json['languageCode'],
        answerLanguageCode = json['answerLanguageCode'],
        isReversible = json['isReversible'] == 'true',
        isActivated = json['isActivated'] == 'true';

  DeckCard();

  @override
  String toString() {
    return 'DeckCard{id: $id, type: $type, isActivated: $isActivated, answers: $answers, question: $question, hint: $hint, languageCode: $languageCode, answerLanguageCode: $answerLanguageCode, isReversible: $isReversible}';
  }
}

List<DeckCard> decodeDeckCardJsonArray(array) {
  if (array == null) {
    return [];
  }
  List<DeckCard> cards = [];
  for (var card in array) {
    cards.add(DeckCard.fromJson(card));
  }
  return cards;
}
