import 'Answer.dart';
import 'DeckCard.dart';

class GrammarPointCard extends DeckCard {
  List<String> gapSentences;
  List<Answer> almostAnswers;

  GrammarPointCard.fromJson(Map<String, dynamic> json)
      : gapSentences = List<String>.from(json['gapSentences']),
        almostAnswers = decodeAnswerJsonArray(json['almostAnswers']);

  @override
  String toString() {
    return 'GrammarPointCard{gapSentences: $gapSentences, almostAnswers: $almostAnswers}';
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
