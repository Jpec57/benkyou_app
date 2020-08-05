import 'dart:io';

import 'package:benkyou/models/DeckCard.dart';
import 'package:benkyou/models/GrammarPointCard.dart';
import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/models/UserCardProcessedInfo.dart';
import 'package:benkyou/models/UserCardReviewCount.dart';
import 'package:benkyou/services/rest.dart';

Future<bool> deleteUserCard(int userCardId) async {
  print("/users/cards/$userCardId");
  HttpClientResponse cardResponse =
      await getLocaleDeleteRequestResponse("/users/cards/$userCardId");
  var cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    print(cards);
    return false;
  }
  return true;
}

Future<UserCard> updateCardAnswers(int userCardId, List<String> answers) async {
  Map map = new Map();
  List<Map> answerArray = [];

  for (String answer in answers) {
    answerArray.add({'text': answer});
  }
  map.putIfAbsent('id', () => userCardId);
  map.putIfAbsent('userAnswers', () => answerArray);
  HttpClientResponse cardResponse =
      await getLocalePostRequestResponse("/users/cards", map);
  var card = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    print(card);
    return null;
  }
  return UserCard.fromId(card);
}

Future<List<UserCard>> getUserJapaneseCardsForDeck(int deckId) async {
  HttpClientResponse cardResponse = await getLocaleGetRequestResponse(
      "/users/decks/$deckId/language/$LANGUAGE_CODE_JAPANESE");
  var cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    print(cards);
    return null;
  }
  List<UserCard> parsedCards = decodeUserCardJsonArray(cards);
  return parsedCards;
}

Future<List<UserCard>> getUserCardsForDeck(int deckId) async {
  HttpClientResponse cardResponse =
      await getLocaleGetRequestResponse("/users/decks/$deckId");
  var cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    print(cards);
    return null;
  }
  List<UserCard> parsedCards = decodeUserCardJsonArray(cards);
  return parsedCards;
}

Future<List<UserCard>> getUserCardsGroupByDeck() async {
  HttpClientResponse cardResponse =
      await getLocaleGetRequestResponse("/users/cards");
  var cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    print(cards);
    return null;
  }
  List<UserCard> parsedCards = decodeUserCardJsonArray(cards);
  return parsedCards;
}

Future<List<UserCard>> getJapaneseUserCardsGroupByDeck() async {
  HttpClientResponse cardResponse = await getLocaleGetRequestResponse(
      "/users/cards/language/$LANGUAGE_CODE_JAPANESE");
  print("/users/cards/language/$LANGUAGE_CODE_JAPANESE");
  var cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    print(cards);
    return null;
  }
  print(cardResponse.statusCode);
  List<UserCard> parsedCards = decodeUserCardJsonArray(cards);
  return parsedCards;
}

Future<List<UserCardReviewCount>> getReviewCardCountsForAllDecks() async {
  HttpClientResponse countResponse =
      await getLocaleGetRequestResponse("/decks/user-card/counts");
  var counts = await getJsonFromHttpResponse(countResponse);
  if (!isRequestValid(countResponse.statusCode)) {
    print(counts);
    return null;
  }
  List<UserCardReviewCount> parsedCounts =
      decodeUserCardReviewCountJsonArray(counts);
  return parsedCounts;
}

Future<List<UserCardReviewCount>> getAwaitingCardCountsForAllDecks() async {
  HttpClientResponse countResponse =
      await getLocaleGetRequestResponse("/decks/user-card/awaiting/counts");
  var counts = await getJsonFromHttpResponse(countResponse);
  if (!isRequestValid(countResponse.statusCode)) {
    print(counts);
    return null;
  }
  List<UserCardReviewCount> parsedCounts =
      decodeUserCardReviewCountJsonArray(counts);
  return parsedCounts;
}

Future<List<UserCard>> getReviewCardsForDeck(int deckId) async {
  HttpClientResponse cardResponse =
      await getLocaleGetRequestResponse("/users/decks/$deckId/review");
  var cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    print(cards);
    return null;
  }
  List<UserCard> parsedCards = decodeUserCardJsonArray(cards);
  return parsedCards;
}

Future<List<UserCard>> getReviewCards() async {
  HttpClientResponse cardResponse =
      await getLocaleGetRequestResponse("/users/decks/review");
  var cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    print(cards);
    return null;
  }
  List<UserCard> parsedCards = decodeUserCardJsonArray(cards);
  return parsedCards;
}

//TODO
Future<List<UserCard>> getGrammarReviewCards() async {
  HttpClientResponse cardResponse =
      await getLocaleGetRequestResponse("/users/grammar-decks/review");
  var cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    print(cards);
    return null;
  }
  List<UserCard> parsedCards = decodeUserCardJsonArray(cards);
  return parsedCards;
}

Future<bool> postReview(List<UserCardProcessedInfo> cards) async {
  Map body = new Map();
  body.putIfAbsent(
      "cards", () => convertUserCardProcessedInfoListToJson(cards));
  HttpClientResponse response =
      await getLocalePostRequestResponse("/review", body);
  var json = await getJsonFromHttpResponse(response);
  if (!isRequestValid(response.statusCode)) {
    print(json);
    return false;
  }
  return true;
}

Future<UserCard> postUserNote(int cardId, String text) async {
  Map body = new Map();
  body.putIfAbsent("text", () => text);
  HttpClientResponse response =
      await getLocalePostRequestResponse("/cards/$cardId/note", body);
  var card = await getJsonFromHttpResponse(response);
  if (!isRequestValid(response.statusCode)) {
    print(response);
    return null;
  }
  return UserCard.fromJson(card);
}

Future<UserCard> addUserAnswer(int cardId, String text) async {
  Map body = new Map();
  body.putIfAbsent("text", () => text);
  HttpClientResponse response =
      await getLocalePostRequestResponse("/cards/$cardId/answers", body);
  var card = await getJsonFromHttpResponse(response);
  if (!isRequestValid(response.statusCode)) {
    print(response);
    return null;
  }
  return UserCard.fromJson(card);
}

///  DECK CARDS

Future<DeckCard> postCard(int deckId, Map body) async {
  HttpClientResponse cardResponse =
      await getLocalePostRequestResponse("/cards", body);
  var cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    return null;
  }
  DeckCard parsedCards = DeckCard.fromJson(cards);
  return parsedCards;
}

//TODO
Future<GrammarPointCard> postGrammarCard(int deckId, Map body) async {
  HttpClientResponse cardResponse =
      await getLocalePostRequestResponse("/grammar-cards", body);
  var cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    return null;
  }
  GrammarPointCard parsedCards = GrammarPointCard.fromJson(cards);
  return parsedCards;
}

Future<List<DeckCard>> getDeckCards(int deckId, {int offset = 0}) async {
  HttpClientResponse cardResponse =
      await getLocaleGetRequestResponse("/decks/$deckId/cards/$offset");
  var cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    print(cards);
    return null;
  }
  List<DeckCard> parsedCards = decodeDeckCardJsonArray(cards);
  print(parsedCards);
  return parsedCards;
}

Future<List<DeckCard>> getCardsByQuestionInDeck(
    int deckId, String question) async {
  Map map = new Map();
  map.putIfAbsent('question', () => question);
  HttpClientResponse cardResponse =
      await getLocalePostRequestResponse("/decks/$deckId/cards/question", map);
  List<dynamic> cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    return null;
  }
  List<DeckCard> parsedCards = decodeDeckCardJsonArray(cards);
  return parsedCards;
}

Future<List<DeckCard>> getRandomThemeCardsInDeck(int deckId, int number) async {
  HttpClientResponse cardResponse = await getLocaleGetRequestResponse(
      "/themes/decks/$deckId/cards/random/$number");
  List<dynamic> cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    return null;
  }
  List<DeckCard> parsedCards = decodeDeckCardJsonArray(cards);
  return parsedCards;
}

Future<int> getUserCardsCount() async {
  HttpClientResponse cardResponse =
      await getLocaleGetRequestResponse("/users/cards/vocab/number");
  var count = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    return null;
  }
  return int.parse(count['number']);
}

Future<bool> getToUnlockNewCards(int deckId) async {
  HttpClientResponse cardResponse =
      await getLocaleGetRequestResponse("/users/decks/$deckId/cards/unlock");
  var count = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    return false;
  }
  return true;
}

Future<List<DeckCard>> getLockedCards(int deckId) async {
  HttpClientResponse cardResponse = await getLocaleGetRequestResponse(
      "/users/decks/$deckId/locked-cards/unlock");
  var cards = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    return null;
  }
  List<DeckCard> parsedCards = decodeDeckCardJsonArray(cards);
  return parsedCards;
}

Future<int> getLockedCardsCount(int deckId) async {
  HttpClientResponse cardResponse = await getLocaleGetRequestResponse(
      "/users/decks/$deckId/locked-cards/count");
  var count = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    return null;
  }
  return int.parse(count['number']);
}
