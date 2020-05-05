class DialogText {
  String text;
  List<DialogText> possibleAnswers;
  String backgroundImg;
  String translation;

  DialogText(this.text, this.possibleAnswers, {this.backgroundImg});

  DialogText.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        possibleAnswers = decodePossibleAnswersJsonArray(json['possibleAnswers']),
        backgroundImg = json['backgroundImg'],
        translation = json['translation']
  ;

  @override
  String toString() {
    return 'DialogText{text: $text, possibleAnswers: $possibleAnswers, backgroundImg: $backgroundImg, translation: $translation}';
  }
}

List<DialogText> decodePossibleAnswersJsonArray(array){
  if (array == null){
    return [];
  }
  List<DialogText> cards = [];
  for (var diagText in array){
    cards.add(DialogText.fromJson(diagText));
  }
  return cards;
}