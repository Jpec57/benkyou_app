import 'DeckCard.dart';
import 'User.dart';

class Deck {
  int id;
  String title;
  User author;
  String description;
  List<DeckCard> cards;
  List<User> users;

  Deck.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        author = User.fromJson(json['author']),
        description = json['description'],
        cards = decodeDeckCardJsonArray(json['cards']),
        users = decodeUserJsonArray(json['users'])
  ;

  @override
  String toString() {
    return 'Deck{id: $id, title: $title, author: $author, description: $description, cards: $cards, users: $users}';
  }
}