import 'Answer.dart';
import 'DeckCard.dart';

class GrammarPointCard extends DeckCard {
  List<String> gapSentences;

  GrammarPointCard.fromJson(Map<String, dynamic> json)
      : gapSentences = List<String>.from(json['gapSentences']);

  @override
  String toString() {
    return 'GrammarPointCard{gapSentences: $gapSentences, parent: ${super.toString()}';
  }
//  int id;
//  String name;
//  Answer meaning;
//  String hint;
//  int languageCode;
//  int answerLanguageCode;
//  bool isActivated;

//  GrammarPointCard(this.id, this.name, this.meaning, this.gapSentences,
//      this.hint, this.languageCode, this.answerLanguageCode, this.isActivated)
//      : super.fromJson(null);
//
//  GrammarPointCard.fromJson(Map<String, dynamic> json)
//      : id = json['id'],
//        meaning = decodeMeaningFromJsonArray(json['answers']),
//        name = json['question'],
//        hint = json['hint'],
//        gapSentences = json['gapSentences'],
//        languageCode = json['languageCode'],
//        answerLanguageCode = json['answerLanguageCode'],
//        isActivated = json['isActivated'] == 'true',
//        super.fromJson(json);
//
//  @override
//  String toString() {
//    return 'GrammarPointCard{id: $id, name: $name, meaning: $meaning, gapSentences: $gapSentences, hint: $hint, languageCode: $languageCode, answerLanguageCode: $answerLanguageCode, isActivated: $isActivated}';
//  }

}

Answer decodeMeaningFromJsonArray(array) {
  if (array == null) {
    return null;
  }
  for (var answer in array) {
    return Answer.fromJson(answer);
  }
  return null;
}
