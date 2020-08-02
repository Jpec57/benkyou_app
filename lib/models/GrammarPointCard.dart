import 'Answer.dart';

class GrammarPointCard {
  int id;
  String name;
  Answer meaning;
  List<String> gapSentences;
  String hint;
  int languageCode;
  int answerLanguageCode;
  bool isActivated;

  GrammarPointCard.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        meaning = decodeMeaningFromJsonArray(json['answers']),
        name = json['question'],
        hint = json['hint'],
        languageCode = json['languageCode'],
        answerLanguageCode = json['answerLanguageCode'],
        isActivated = json['isActivated'] == 'true';

  @override
  String toString() {
    return 'GrammarPointCard{id: $id, name: $name, meaning: $meaning, gapSentences: $gapSentences, hint: $hint, languageCode: $languageCode, answerLanguageCode: $answerLanguageCode, isActivated: $isActivated}';
  }
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
