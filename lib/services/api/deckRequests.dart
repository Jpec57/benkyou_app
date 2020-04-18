import '../../models/Deck.dart';
import '../rest.dart';

Future<List<Deck>> getPersonalDecks() async {
  List<Deck> parsedDecks = [];
  List<dynamic> decks = await makeLocaleGetRequest("/decks/me");
  for (Map<String, dynamic> deck in decks){
    parsedDecks.add(Deck.fromJson(deck));
  }
  return parsedDecks;
}

Future<Deck> getDeck(int id) async {
  Map<String, dynamic> deck = await makeLocaleGetRequest("/decks/$id");
  return Deck.fromJson(deck);
}

Future<Deck> postDeck(String title) async {
  Map map = new Map();
  map.putIfAbsent('title', ()=> title);
  Map<String, dynamic> deck = await makeLocalePostRequest("/decks", map);
  return Deck.fromJson(deck);
}