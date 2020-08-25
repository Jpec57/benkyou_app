class User {
  int id;
  String username;
  String email;
  int grammarXp;
  int vocabXp;
  int oralComprehensionXp;
  int writingComprehensionXp;
  int writingExpressionXp;
  DateTime lastActivity;
  int consecutiveActivityDays;
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
        lastActivity =
            json.containsKey('lastActivity') && json['lastActivity'] != null
                ? DateTime.parse(json['lastActivity'])
                : null,
        consecutiveActivityDays = json.containsKey('consecutiveActivityDays')
            ? json['consecutiveActivityDays']
            : 0,
        writingExpressionXp = json['writingExpressionXp'];

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, grammarXp: $grammarXp, vocabXp: $vocabXp, oralComprehensionXp: $oralComprehensionXp, writingComprehensionXp: $writingComprehensionXp, writingExpressionXp: $writingExpressionXp, lastActivity: $lastActivity, consecutiveActivityDays: $consecutiveActivityDays, likes: $likes, likedUsers: $likedUsers}';
  }
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
