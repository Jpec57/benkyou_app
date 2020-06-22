import 'package:benkyou/models/User.dart';
import 'package:benkyou/utils/utils.dart';

import 'DeckTheme.dart';

class Sentence {
  int id;
  int languageCode;
  String text;
  String hint;
  User author;
  List<Sentence> translations;
  bool isQuestion;
  int complexity;
  List<DeckTheme> sentenceThemes;

  Sentence(this.id, this.languageCode, this.text, this.author,
      this.translations, this.isQuestion, this.complexity, this.sentenceThemes);

  Sentence.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        languageCode = json['languageCode'],
        text = json['text'],
        author = json['author'] != null ? User.fromJson(json['author']) : null,
        translations = decodeSentencesJsonArray(json['translations']),
        isQuestion = json['isQuestion'] == 'true',
        complexity = json['complexity'],
        hint = getFromJson(json, 'hint'),
        sentenceThemes = decodeDeckThemesJsonArray(json['sentenceThemes'])
  ;

  @override
  String toString() {
    return 'Sentence{id: $id, languageCode: $languageCode, text: $text, hint: $hint, author: $author, translations: $translations, isQuestion: $isQuestion, complexity: $complexity, sentenceThemes: $sentenceThemes}';
  }
}

//TODO

List<Sentence> decodeSentencesJsonArray(array){
  if (array == null){
    return [];
  }
  List<Sentence> sentences = [];
  for (var card in array){
    sentences.add(Sentence.fromJson(card));
  }
  return sentences;
}