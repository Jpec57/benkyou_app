import 'package:benkyou/models/DialogText.dart';
import 'package:benkyou/models/User.dart';

class UserDialog {
  String title;
  String description;
  DialogText firstDialog;
  User author;

  UserDialog.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        description = json['description'],
        firstDialog = DialogText.fromJson(json['firstDialog']),
  //TODO
        author = json['author']
  ;

  @override
  String toString() {
    return 'UserDialog{title: $title, description: $description, firstDialog: $firstDialog, author: $author}';
  }
}