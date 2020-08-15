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
