class User {
  int id;
  String username;
  String email;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        email = json['email']
  ;
}

List<User> decodeUserJsonArray(array){
  List<User> users = [];

  if (array == null){
    return [];
  }
  for (var user in array){
    users.add(User.fromJson(user));
  }
  return users;
}