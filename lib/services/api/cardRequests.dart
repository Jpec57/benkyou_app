import 'package:benkyou_app/models/UserCard.dart';
import 'package:benkyou_app/services/rest.dart';

Future<List<UserCard>> getUserCardsForDeck(int deckId) async {
  List<dynamic> cards = await makeLocaleGetRequest("/users/decks/$deckId");
  List<UserCard> parsedCards = decodeUserCardJsonArray(cards);
  return parsedCards;
}

Future<List<UserCard>> getReviewCardsForDeck(int deckId) async {
  List<dynamic> cards = await makeLocaleGetRequest("/users/decks/$deckId/review");
  List<UserCard> parsedCards = decodeUserCardJsonArray(cards);
  return parsedCards;
}