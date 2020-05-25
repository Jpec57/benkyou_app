import 'package:benkyou/models/DialogText.dart';
import 'package:benkyou/models/User.dart';

class UserDialog {
  int id;
  String title;
  String description;
  DialogText firstDialog;
  User author;

  UserDialog.fromJson(Map<String, dynamic> json)
      :
        id = json['id'],
        title = json['title'],
        description = json['description'],
        firstDialog = DialogText.fromJson(json['firstDialog']),
        author = json['author']
  ;

  @override
  String toString() {
    return 'UserDialog{id: $id, title: $title, description: $description, firstDialog: $firstDialog, author: $author}';
  }
}