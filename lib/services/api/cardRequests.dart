import 'package:benkyou_app/models/DeckCard.dart';
import 'package:benkyou_app/models/UserCard.dart';
import 'package:benkyou_app/models/UserCardProcessedInfo.dart';
import 'package:benkyou_app/services/rest.dart';

Future<List<UserCard>> getUserCardsForDeck(int deckId) async {
  var cards = await makeLocaleGetRequest("/users/decks/$deckId");
  List<UserCard> parsedCards = decodeUserCardJsonArray(cards);
  return parsedCards;
}

Future<List<UserCard>> getReviewCardsForDeck(int deckId) async {
  var cards = await makeLocaleGetRequest("/users/decks/$deckId/review");
  List<UserCard> parsedCards = decodeUserCardJsonArray(cards);
  return parsedCards;
}

Future<bool> postReview(List<UserCardProcessedInfo> cards) async {
  Map body = new Map();
  body.putIfAbsent("cards", ()=> convertUserCardProcessedInfoListToJson(cards));
  await makeLocalePostRequest("/review", body);
  return true;
}


///  DECK CARDS

Future<DeckCard> postCard(int deckId, Map body) async {
  var cards = await makeLocalePostRequest("/cards", body);
  DeckCard parsedCards = DeckCard.fromJson(cards);
  return parsedCards;
}

Future<List<DeckCard>> getCardsByQuestionInDeck(int deckId, String question) async {
  Map map = new Map();
  map.putIfAbsent('question', () => question);
  List<dynamic> cards = await makeLocalePostRequest("/decks/$deckId/cards/question", map);
  List<DeckCard> parsedCards = decodeDeckCardJsonArray(cards);
  return parsedCards;
}