class UserCardProcessedInfo {
  int id;
  int cardId;
  bool isSuccess;

  UserCardProcessedInfo(this.id, this.cardId, this.isSuccess);

  Map<String, dynamic> toJson() => {
        'userCardId': id,
        'cardId': cardId,
        'isSuccess': isSuccess,
      };
}

convertUserCardProcessedInfoListToJson(List<UserCardProcessedInfo> cards){
  List<Map> mapArray = [];
  for (UserCardProcessedInfo card in cards){
    mapArray.add(card.toJson());
  }
  return mapArray;
}
