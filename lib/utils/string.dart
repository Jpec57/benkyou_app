import 'dart:math';

import 'hiraganaPhoneticsGroups.dart';

String getTrimmedLowerString(String string) {
  return string.trim().toLowerCase();
}

String getAnswerWithoutInfo(String answer) {
  RegExp regExp = RegExp(r'\(.*\)');
  return answer.replaceAll(regExp, '').trim();
}

int stringDistance(String s1, String s2, {bool watchCase = false}) {
  if (s1.isEmpty || s2.isEmpty) {
    return max(s1.length, s2.length);
  }
  if (!watchCase) {
    s1 = getTrimmedLowerString(s1);
    s2 = getTrimmedLowerString(s2);
  }

  int inf = s1.length + s2.length;

  Map<int, int> da = new Map<int, int>();

  for (var d = 0; d < s1.length; d++) {
    if (!da.containsKey(s1.codeUnitAt(d))) {
      da[s1.codeUnitAt(d)] = 0;
    }
  }

  for (var d = 0; d < s2.length; d++) {
    if (!da.containsKey(s2.codeUnitAt(d))) {
      da[s2.codeUnitAt(d)] = 0;
    }
  }

  List<List<int>> h = new List<List<int>>(s1.length + 2)
      .map((_) => new List<int>.filled(s2.length + 2, 0))
      .toList();

  for (var i = 0; i <= s1.length; i++) {
    h[i + 1][0] = inf;
    h[i + 1][1] = i;
  }

  for (var j = 0; j <= s2.length; j++) {
    h[0][j + 1] = inf;
    h[1][j + 1] = j;
  }

  for (var i = 1; i <= s1.length; i++) {
    int db = 0;

    for (var j = 1; j <= s2.length; j++) {
      int i1 = da[s2.codeUnitAt(j - 1)];
      int j1 = db;

      int cost = 1;
      if (s1.codeUnitAt(i - 1) == s2.codeUnitAt(j - 1)) {
        cost = 0;
        db = j;
      }

      h[i + 1][j + 1] = [
        h[i][j] + cost, // substitution
        h[i + 1][j] + 1, // insertion
        h[i][j + 1] + 1, // deletion
        h[i1][j1] + (i - i1 - 1) + 1 + (j - j1 - 1)
      ].reduce((acc, val) => min(acc, val));
    }
    da[s1.codeUnitAt(i - 1)] = i;
  }

  return h[s1.length + 1][s2.length + 1];
}

double normalizedStringDistance(String s1, String s2) {
  int maxLength = max(s1.length, s2.length);
  if (maxLength == 0) {
    return 0.0;
  }
  return stringDistance(s1, s2) / maxLength;
}

bool isStringDistanceValid(String s1, String s2) {
  return (1 - normalizedStringDistance(s1, s2)) >= 0.8;
}

String replaceCharPhoneticAt(Random random, String oldString, int index) {
  List<String> group = [];
  String oldChar = oldString[index];
  PHONETIC_GROUPS.forEach((key, List<String> value) {
    for (String phoneme in value) {
      if (oldChar == HIRAGANA_ALPHABET_MAPPING[phoneme]) {
        value.forEach((element) {
          group.add(HIRAGANA_ALPHABET_MAPPING[element]);
        });
        break;
      }
    }
  });
  if (group.isEmpty) {
    return null;
  }
  group.remove(oldChar);
  String newChar = group[random.nextInt(group.length)];
  return oldString.substring(0, index) +
      newChar +
      oldString.substring(index + 1);
}

List<String> getSentenceBadVariations(String sentence,
    {int number = 3, int nbChanges = 2}) {
  Random random = new Random();
  List<String> list = [];
  for (int i = 0; i < number; i++) {
    int length = sentence.length;
    String oldString = sentence;
    String newString;
    int retry = 3;
    for (int j = 0; j < nbChanges; j++) {
      int pos = random.nextInt(length);
      newString = replaceCharPhoneticAt(random, oldString, pos);
      if (newString != null) {
        oldString = newString;
      } else {
        retry--;
        if (retry > 0) {
          j--;
        }
      }
    }
    list.add(oldString);
  }
  return list;
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

List<List<String>> getAcceptedAnswerFromGrammarSentences(String sentence) {
  List<List<String>> answers = [];
  RegExp regExp = new RegExp(r"{[^}]+}");
  Iterable<RegExpMatch> matches = regExp.allMatches(sentence);
  for (var match in matches) {
    List<String> answersForOneGap = [];
    String desiredString =
        sentence.substring(match.start + 1, match.end - 1).trim();
    if (desiredString.contains('/')) {
      answersForOneGap = desiredString.split('/');
    } else {
      answersForOneGap.add(desiredString);
    }
    answers.add(answersForOneGap);
  }
  return answers;
}
