class User {
  int id;
  String username;
  String email;
  int grammarXp;
  int vocabXp;
  int oralComprehensionXp;
  int writingComprehensionXp;
  int writingExpressionXp;
  List<User> likes;
  List<User> likedUsers;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        email = json['email'],
        grammarXp = json['grammarXp'],
        vocabXp = json['vocabularyXp'],
        oralComprehensionXp = json['oralComprehensionXp'],
        writingComprehensionXp = json['writingComprehensionXp'],
        writingExpressionXp = json['writingExpressionXp'];
}

List<User> decodeUserJsonArray(array) {
  List<User> users = [];

  if (array == null) {
    return [];
  }
  for (var user in array) {
    users.add(User.fromJson(user));
  }
  return users;
}
