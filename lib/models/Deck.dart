import 'package:benkyou/utils/utils.dart';

import 'DeckCard.dart';
import 'User.dart';

class Deck {
  int id;
  String title;
  User author;
  String description;
  List<DeckCard> cards;
  List<User> users;
  bool isPublic;
  bool isOfficial;
  bool isMuted;
  int cardType;

  Deck.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = getFromJson(json, 'title'),
        author = json['author'] != null ? User.fromJson(json['author']) : null,
        description = getFromJson(json, 'description'),
        cards = json.containsKey('cards')
            ? decodeDeckCardJsonArray(json['cards'])
            : [],
        users = decodeUserJsonArray(json['users']),
        isPublic = json['isPublic'] ?? false,
        isOfficial = json['isOfficial'] ?? false,
        isMuted = json.containsKey('isMuted') ? json['isMuted'] : false,
        cardType = json.containsKey('cardType') ? json['cardType'] : 0;

  Deck.fromId(Map<String, dynamic> json) : id = json['id'];

  @override
  String toString() {
    return 'Deck{id: $id, title: $title, author: $author, description: $description, cards: $cards, users: $users, isPublic: $isPublic, isOfficial: $isOfficial, isMuted: $isMuted, cardType: $cardType}';
  }
}
