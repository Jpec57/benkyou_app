import 'dart:io';

import 'package:benkyou/services/localStorage/localStorageService.dart';

import '../../models/Deck.dart';
import '../rest.dart';

Future<Deck> publishDeck(int id, bool makePublic) async {
  Map map = new Map();
  if (makePublic) {
    map.putIfAbsent('isPublic', () => makePublic);
  }
  HttpClientResponse response =
      await getLocalePostRequestResponse("/decks/$id/publish", map);
  if (!isRequestValid(response.statusCode)) {
    print("publish Deck error");
    print(await getJsonFromHttpResponse(response));
    return null;
  }
  Map<String, dynamic> deck = await getJsonFromHttpResponse(response);
  return Deck.fromJson(deck);
}

Future<Deck> importDeck(int id) async {
  HttpClientResponse response =
      await getLocaleGetRequestResponse("/decks/$id/import");
  if (!isRequestValid(response.statusCode)) {
    print("import Deck error");
    print(await getJsonFromHttpResponse(response));
    return null;
  }
  Map<String, dynamic> deck = await getJsonFromHttpResponse(response);
  print(deck);
  return Deck.fromJson(deck);
}

Future<List<Deck>> getPublicDecks() async {
  List<Deck> parsedDecks = [];
  HttpClientResponse response = await getLocaleGetRequestResponse("/decks");
  if (!isRequestValid(response.statusCode)) {
    return null;
  }
  List<dynamic> decks = await getJsonFromHttpResponse(response);
  for (Map<String, dynamic> deck in decks) {
    print(deck);
    parsedDecks.add(Deck.fromJson(deck));
  }

  return parsedDecks;
}

Future<List<Deck>> getGrammarDecks() async {
  List<Deck> parsedDecks = [];
  HttpClientResponse response =
      await getLocaleGetRequestResponse("/grammar-decks");
  if (!isRequestValid(response.statusCode)) {
    print(await getJsonFromHttpResponse(response));
    return null;
  }

  List<dynamic> decks = await getJsonFromHttpResponse(response);
  for (Map<String, dynamic> deck in decks) {
    parsedDecks.add(Deck.fromJson(deck));
  }
  return parsedDecks;
}

Future<List<Deck>> getPersonalDecks() async {
  List<Deck> parsedDecks = [];
  HttpClientResponse response =
      await getLocaleGetRequestResponse("/users/decks");
  if (!isRequestValid(response.statusCode)) {
    print(await getJsonFromHttpResponse(response));
    return null;
  }

  List<dynamic> decks = await getJsonFromHttpResponse(response);
  for (Map<String, dynamic> deck in decks) {
    parsedDecks.add(Deck.fromJson(deck));
  }
  return parsedDecks;
}

Future<Deck> getDeck(int id) async {
  HttpClientResponse response = await getLocaleGetRequestResponse("/decks/$id");
  if (!isRequestValid(response.statusCode)) {
    return null;
  }
  Map<String, dynamic> deck = await getJsonFromHttpResponse(response);
  return Deck.fromJson(deck);
}

Future<Deck> postDeck(String title, String description,
    {int deckId, bool isGrammar = false}) async {
  Map map = new Map();
  if (deckId != null) {
    map.putIfAbsent('id', () => deckId);
  }
  map.putIfAbsent('title', () => title);
  map.putIfAbsent('description', () => description);
  map.putIfAbsent('cardType', () => isGrammar ? 1 : 0);
  HttpClientResponse response =
      await getLocalePostRequestResponse("/decks", map);
  if (!isRequestValid(response.statusCode)) {
    print(await getJsonFromHttpResponse(response));
    return null;
  }
  Map<String, dynamic> deck = await getJsonFromHttpResponse(response);
  print(deck);
  return Deck.fromJson(deck);
}

Future<bool> deleteDeck(int deckId) async {
  int saveDeckId = await getLastUsedDeckIdFromLocalStorage();
  if (saveDeckId == deckId) {
    await setLastUsedDeckIdFromLocalStorage(null);
  }
  HttpClientResponse response =
      await getLocaleDeleteRequestResponse("/decks/$deckId");
  if (!isRequestValid(response.statusCode)) {
    print(await getJsonFromHttpResponse(response));
    return false;
  }
  return true;
}
