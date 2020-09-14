import 'Answer.dart';
import 'DeckCard.dart';

class GrammarPointCard extends DeckCard {
  List<String> gapSentences;
  List<String> acceptedAnswers;

  GrammarPointCard.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    gapSentences = List<String>.from(json['gapSentences']);
    acceptedAnswers = json['acceptedAnswers'] != null
        ? List<String>.from(json['acceptedAnswers'])
        : [];
  }

  @override
  String toString() {
    return 'GrammarPointCard{gapSentences: $gapSentences, acceptedAnswers: $acceptedAnswers, ${super.toString()}';
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
