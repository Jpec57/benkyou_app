import 'package:benkyou/models/Deck.dart';

import 'Sentence.dart';

class DeckTheme {
  int id;
  String name;
  String backgroundImg;
  List<String> keywords;
  Deck deck;
  List<Sentence> sentences;

  DeckTheme(this.id, this.name, this.backgroundImg, this.keywords, this.deck,
      this.sentences);

  DeckTheme.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        backgroundImg = json['backgroundImg'],
        deck = Deck.fromId(json['deck']),
        sentences = decodeSentencesJsonArray(json['sentences'])
  ;
}

List<DeckTheme> decodeDeckThemesJsonArray(array){
  if (array == null){
    return [];
  }
  List<DeckTheme> themes = [];
  for (var theme in array){
    themes.add(DeckTheme.fromJson(theme));
  }
  return themes;
}