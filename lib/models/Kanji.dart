class Kanji {
  int id;
  String symbol;
  int jouyouLevel;
  int jlptLevel;
  List<String> readings;
  List<String> meanings;

  Kanji(this.id, this.symbol, this.jouyouLevel, this.jlptLevel, this.readings,
      this.meanings);

  factory Kanji.fromJson(Map<String, dynamic> json) {
    return Kanji(
      json['id'],
      json['symbol'],
      json['jouyouLevel'],
      json['jlptLevel'],
      decodeListStringJsonArray(json['readings']),
      decodeListStringJsonArray(json['meanings']),
    );
  }

  @override
  String toString() {
    return 'Kanji{id: $id, symbol: $symbol, jouyouLevel: $jouyouLevel, jlptLevel: $jlptLevel, readings: $readings, meanings: $meanings}';
  }
}

List<String> decodeListStringJsonArray(array) {
  if (array == null) {
    return [];
  }
  List<String> cards = [];
  for (var str in array) {
    cards.add(str);
  }
  return cards;
}
