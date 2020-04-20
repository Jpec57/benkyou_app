class UserCardReviewCount{
  int deckId;
  int count;

  UserCardReviewCount(this.deckId, this.count);

  UserCardReviewCount.fromJson(Map<String, dynamic> json)
      : deckId = json['deckId'],
        count = int.parse(json['count'])
  ;

  Map<String, dynamic> toJson() => {
    'deckId': deckId,
    'count': count,
  };
}

List<UserCardReviewCount> decodeUserCardReviewCountJsonArray(array){
  if (array == null){
    return [];
  }
  List<UserCardReviewCount> cards = [];
  for (var card in array){
    cards.add(UserCardReviewCount.fromJson(card));
  }
  return cards;
}