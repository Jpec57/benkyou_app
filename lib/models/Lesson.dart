import 'package:benkyou/models/User.dart';

class Lesson {
  int id;
  String title;
  String description;
  User author;
  String content;
  String videoUrl;
  String banniere;


  Lesson.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        description = json['description'],
        author =  json['author'] != null ? User.fromJson(json['author']) : null,
        content = json['content'],
        videoUrl = json['videoUrl'],
        banniere = json['banniere']
  ;

  @override
  String toString() {
    return 'Lesson{title: $title, description: $description, content: $content, videoUrl: $videoUrl, banniere: $banniere}';
  }
}

List<Lesson> decodeLessonsJsonArray(array){
  if (array == null){
    return [];
  }
  List<Lesson> lessons = [];
  for (var diagText in array){
    lessons.add(Lesson.fromJson(diagText));
  }
  return lessons;
}