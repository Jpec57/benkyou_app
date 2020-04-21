import '../../models/Deck.dart';
import '../rest.dart';
import 'dart:io';

Future<List<Deck>> getPersonalDecks() async {
  List<Deck> parsedDecks = [];
  HttpClientResponse response = await getLocaleGetRequestResponse("/decks/me");
  if (!isRequestValid(response.statusCode)){
    return null;
  }
  List<dynamic> decks = await getJsonFromHttpResponse(response);
  for (Map<String, dynamic> deck in decks){
    parsedDecks.add(Deck.fromJson(deck));
  }
  return parsedDecks;
}

Future<Deck> getDeck(int id) async {
  HttpClientResponse response = await getLocaleGetRequestResponse("/decks/$id");
  if (!isRequestValid(response.statusCode)){
    return null;
  }
  Map<String, dynamic> deck = await getJsonFromHttpResponse(response);
  return Deck.fromJson(deck);
}

Future<Deck> postDeck(String title) async {
  Map map = new Map();
  map.putIfAbsent('title', ()=> title);
  HttpClientResponse response = await getLocalePostRequestResponse("/decks", map);
  if (!isRequestValid(response.statusCode)){
    print(await getJsonFromHttpResponse(response));
    return null;
  }
  Map<String, dynamic> deck = await getJsonFromHttpResponse(response);
  return Deck.fromJson(deck);
}