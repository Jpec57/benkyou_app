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

  Deck.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = getFromJson(json, 'title'),
        author = User.fromJson(json['author']),
        description = getFromJson(json, 'description'),
        cards = decodeDeckCardJsonArray(json['cards']),
        users = decodeUserJsonArray(json['users']),
        isPublic = json['isPublic'] ?? false
  ;

  Deck.fromId(Map<String, dynamic> json)
      : id = json['id']
  ;

  @override
  String toString() {
    return 'Deck{id: $id, title: $title, author: $author, description: $description, cards: $cards, users: $users}';
  }
}