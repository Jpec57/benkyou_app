import 'dart:io';

import 'package:benkyou/services/localStorage/localStorageService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

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

Future<ImageProvider> getDeckCover(int id, String coverPath) async {
  if (coverPath == null) {
    return null;
  }
  //get locale image if exists
  final String path = (await getApplicationDocumentsDirectory()).path;
  File file = File('$path/DeckCover-$id.png');
  bool isExisting = await file.exists();
  if (isExisting) {
    return FileImage(file);
  }
  //end
  try {
    Response response = await getFileRequestResponse("/decks/$id/cover");
    if (!isRequestValid(response.statusCode)) {
      return null;
    }
    var bytes = response.bodyBytes;
    if (bytes != null) {
      return MemoryImage(bytes);
    }
  } catch (e) {
    print(e);
  }

  return null;
}

Future<Deck> postDeck(String title, String description,
    {int deckId, bool isGrammar = false, String cover}) async {
  Map map = new Map();
  if (deckId != null) {
    map.putIfAbsent('id', () => deckId);
  }
  map.putIfAbsent('title', () => title);
  map.putIfAbsent('description', () => description);
  map.putIfAbsent('cardType', () => isGrammar ? 1 : 0);
  map.putIfAbsent('cover', () => cover);
  HttpClientResponse response =
      await getLocalePostRequestResponse("/decks", map);
  if (!isRequestValid(response.statusCode)) {
    print(await getJsonFromHttpResponse(response));
    return null;
  }
  Map<String, dynamic> deck = await getJsonFromHttpResponse(response);
  return Deck.fromJson(deck);
}

Future<void> removeDeckCover(int deckId) async {
  final String path = (await getApplicationDocumentsDirectory()).path;
  File jpegFile = File('$path/DeckCover-$deckId.jpeg');
  bool exist = await jpegFile.exists();
  if (exist) {
    jpegFile.delete();
  } else {
    File pngFile = File('$path/DeckCover-$deckId.png');
    bool exist = await pngFile.exists();
    if (exist) {
      pngFile.delete();
    }
  }
}

Future<bool> deleteDeck(int deckId) async {
  int saveDeckId = await getLastUsedDeckIdFromLocalStorage();
  if (saveDeckId == deckId) {
    await setLastUsedDeckIdFromLocalStorage(null);
  }
  removeDeckCover(deckId);
  HttpClientResponse response =
      await getLocaleDeleteRequestResponse("/decks/$deckId");
  if (!isRequestValid(response.statusCode)) {
    print(await getJsonFromHttpResponse(response));
    return false;
  }
  return true;
}
