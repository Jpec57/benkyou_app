import 'package:benkyou/services/translator/CONVERSION_CONSTANTS.dart';

const HAh = 12399;
const HAk = 12495;
const WAhk = 12431;
const TSUh = 12387;
const TSUk = 12483;

const YAh = 12419;
const YAk = 12515;
const YUh = 12421;
const YUk = 12517;
const YOh = 12423;
const YOk = 12519;
//https://stackoverflow.com/questions/43418812/check-whether-a-string-contains-japanese-chinese-characters
bool doesStringContainsJapaneseCharacters(String input) {
  return isHiragana(input) ||
      isKatakana(input) ||
      doesStringContainsKanji(input);
}

bool doesStringContainsKanji(String input) {
  RegExp regExp =
      new RegExp("/[\u3400-\u4dbf]|[\u4e00-\u9fff]|[\uf900-\ufaff]/");
  return regExp.hasMatch(input);
}

bool isHiragana(String input) {
  RegExp regExp = new RegExp('/[\u3040-\u309F]/g');
  return regExp.hasMatch(input);
}

bool isKatakana(String input) {
  RegExp regExp =
      new RegExp('/[\uFF00-\uFFEF]|[\u30A0-\u30FF]|[\u3040-\u309Fー]+/g');
  return regExp.hasMatch(input);
}

RegExp _alpha = RegExp(r'^[a-zA-Z]+$');
bool isAlpha(String str) {
  return _alpha.hasMatch(str);
}

bool hasAlpha(String str) {
  RegExp _alpha = RegExp(r'[a-zA-Z]+');

  return _alpha.hasMatch(str);
}

List<String> separateKanaWords(String str) {
  List<String> list = [];
  int strLength = str.length;
  int i = 0;
  int j;
  while (i < strLength) {
    //Lowercase
    j = 0;
    while (i + j < strLength && str[i + j].toLowerCase() == str[i + j]) {
      j++;
    }
    if (j > 0) {
      list.add(str.substring(i, j + i));
    }
    i = i + j;
    //Uppercase
    j = 0;
    while (i + j < strLength && str[i + j].toUpperCase() == str[i + j]) {
      j++;
    }
    if (j > 0) {
      list.add(str.substring(i, j + i));
    }
    i = i + j;
    //Other
    j = 0;
    while (i + j < strLength && !isAlpha(str[i + j])) {
      j++;
    }
    if (j > 0) {
      list.add(str.substring(i, j + i));
    }
    i = i + j;
  }
  return list;
}

String getDynamicHiraganaConversion(String val,
    {bool onlyJapanese = false, bool hasSpace = true}) {
  if (val.isEmpty) {
    return '';
  }
  //if character is a kanji, skip
  if (doesStringContainsKanji(val)) {
    return val;
  }
  String romaji = getRomConversion(val, isDynamic: true);

  List<String> words = separateKanaWords(romaji);
  String res = "";
  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      String firstLetter = words[i][0];
      bool isKatakana = firstLetter == firstLetter.toUpperCase();
      res += getConversion(
              words[i],
              isKatakana
                  ? DYNAMIC_KATAKANA_ALPHABET
                  : DYNAMIC_HIRAGANA_ALPHABET,
              onlyJapanese: onlyJapanese,
              hasSpace: hasSpace) ??
          '';
    }
  }
  return res;
}

String getJapaneseTranslation(String val,
    {bool onlyJapanese = false, bool hasSpace = true}) {
  if (val.isEmpty) {
    return '';
  }
  Map<int, Map<String, String>> alphabet =
      (val[0].toUpperCase() == val[0]) ? KATAKANA_ALPHABET : HIRAGANA_ALPHABET;
  return getConversion(val, alphabet,
          onlyJapanese: onlyJapanese, hasSpace: hasSpace) ??
      '';
}

String getHiragana(String val,
    {bool isStaticAnalysis = false,
    bool onlyJapanese = false,
    bool hasSpace = true}) {
  return getConversion(val, HIRAGANA_ALPHABET,
      onlyJapanese: onlyJapanese,
      hasSpace: hasSpace,
      isStaticAnalysis: isStaticAnalysis);
}

String getKatakana(String val,
    {bool isStaticAnalysis = false,
    bool onlyJapanese = false,
    bool hasSpace = true}) {
  return getConversion(val, KATAKANA_ALPHABET,
      onlyJapanese: onlyJapanese,
      hasSpace: hasSpace,
      isStaticAnalysis: isStaticAnalysis);
}

String getRomaji(int val, {bool isDynamic = false}) {
  if (isDynamic == true) {
    return DYNAMIC_ROM[val];
  }
  return ROMAJI[val];
}

String getRomConversion(String val,
    {bool onlyRomaji = false,
    isStaticAnalysis = true,
    bool isDynamic = false}) {
  var res = "";
  RegExp regExp = RegExp(' |　');
  List<String> listStrings = val.split(regExp);
  int nbStrings = listStrings.length;
  for (var i = 0; i < nbStrings; i++) {
    String wordRes = getWordToRom(listStrings[i],
        onlyRomaji: onlyRomaji,
        isStaticAnalysis: isStaticAnalysis,
        isDynamic: isDynamic);
    if (wordRes != null) {
      res += wordRes;
    }
    if (i < nbStrings - 1) {
      res += ' ';
    }
  }
  return res;
}

String getWordToRom(String word,
    {bool onlyRomaji = false,
    bool isUppercase = false,
    bool isStaticAnalysis = false,
    bool isDynamic = false}) {
  String res = "";

  int wordLength = word.length;
  for (var j = 0; j < wordLength; j++) {
    int ch = word.codeUnitAt(j);
    bool isKata = isKatakana(word[j]);
    if (!isStaticAnalysis && (ch == HAk || ch == HAh) && word.length == 1) {
      ch = WAhk;
    }
    if ((ch == TSUh || ch == TSUk)) {
      String nextch = (j + 1 < wordLength)
          ? getRomaji(word.codeUnitAt(j + 1), isDynamic: isDynamic)
          : null;
      if (nextch != null) {
        res += (isKata
            ? nextch.substring(0, 1).toUpperCase()
            : nextch.substring(0, 1));
        j++;
        ch = word.codeUnitAt(j);
      }
    }

    String tmpch = getRomaji(ch, isDynamic: isDynamic);
    int nch = (j + 1 < wordLength) ? word.codeUnitAt(j + 1) : null;
    if (tmpch != null &&
        nch != null &&
        (nch == YAh ||
            nch == YAk ||
            nch == YUh ||
            nch == YUk ||
            nch == YOh ||
            nch == YOk)) {
      String beg = tmpch.substring(0, tmpch.length - 1);
      String en = getRomaji((nch + 1), isDynamic: isDynamic);
      if (beg == 'sh' || beg == 'ch' || beg == 'j') {
        tmpch = beg + en.substring(1);
      } else {
        tmpch = beg + en;
      }
      j++;
    }
    if (tmpch != null) {
      res += isKata ? tmpch.toUpperCase() : tmpch;
    } else {
      //Add the non-translated term to the string for continuous translation
      if (!onlyRomaji) {
        res += word[j];
      }
    }
  }
  return res;
}

String getMatchingCharacterInAlphabet(int nbCaracters, val, alphabet) {
  if (val == null) {
    return null;
  }
  var obj = alphabet[nbCaracters];
  return obj[val];
}

String getSafeSubstring(String str, int startIndex, int size, int strLength) {
  return (strLength < startIndex + size)
      ? null
      : str.substring(startIndex, startIndex + size);
}

String getConversion(String val, alphabet,
    {bool isStaticAnalysis = false,
    bool onlyJapanese = false,
    bool hasSpace = true}) {
  int i = 0;
  String res = "";
  String tmpChar;
  int wordLength;
  List<String> wordList = val.toLowerCase().split(" ");
  int listLength = wordList.length;

  for (int j = 0; j < listLength; j++) {
    String word = wordList[j];
    i = 0;
    wordLength = word.length;
    if (wordLength == 0) {
      continue;
    }

    while (i < wordLength) {
      if (!isAlpha(word[i])) {
        res += word[i];
        i++;
        continue;
      }
      //3 letter syllable
      tmpChar = getMatchingCharacterInAlphabet(
          3, getSafeSubstring(word, i, 3, wordLength), alphabet);

      //Compound syllable
      if (tmpChar == null) {
        var ch1 = getSafeSubstring(word, i, 1, wordLength);
        var ch2 = getSafeSubstring(word, i + 1, 2, wordLength);

        if (ch1 != null &&
            ch2 != null &&
            ch1 != 'n' &&
            getMatchingCharacterInAlphabet(2, ch2, alphabet) != null &&
            (ch1 == getSafeSubstring(ch2, 0, 1, 2))) {
          tmpChar = getMatchingCharacterInAlphabet(2, ch2, alphabet);
          res += getMatchingCharacterInAlphabet(4, "tsu", alphabet);
        }
      }

      //2 letter syllable
      if (tmpChar != null) {
        i += 2;
      } else {
        var char = getSafeSubstring(word, i, 2, wordLength);
        //Particular case working only in static analysis
        if (isStaticAnalysis && char == 'wa' && char == word) {
          char = "ha";
        }
        tmpChar = getMatchingCharacterInAlphabet(2, char, alphabet);
        if (tmpChar != null) {
          i += 1;
        } else {
          //1 letter syllable
          tmpChar = getMatchingCharacterInAlphabet(
              1, getSafeSubstring(word, i, 1, wordLength), alphabet);
        }
      }
      //particular case with little tsu then three characters like sshi cchi ttsu
      var ch3 = getSafeSubstring(word, i + 1, 3, wordLength);
      if (tmpChar == null && ch3 != null) {
        res += getMatchingCharacterInAlphabet(4, "tsu", alphabet);
        tmpChar = getMatchingCharacterInAlphabet(3, ch3, alphabet);
        i += 3;
      }
      // We've found a solution with 1, 2 or 3 characters
      if (tmpChar != null) {
        res += tmpChar;
      } else {
        //Add the non-translated term to the string for continuous translation
        if (!onlyJapanese) {
          res += word[i];
        }
      }
      i++;
    }
    if (hasSpace && j != listLength - 1) {
      res += " ";
    }
  }
  return res;
}
