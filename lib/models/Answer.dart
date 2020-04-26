import 'package:benkyou/utils/string.dart';

class Answer{
  int id;
  String text;
  int type;

  Answer.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'],
        type = json['type']
  ;

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'type': type,
  };

  @override
  String toString() {
    return 'Answer{id: $id, text: $text, type: $type}';
  }

  List<Map> encodeAnswerJsonArray(array){
    List<Map> mapArray = [];
    for (Answer answer in array){
      mapArray.add(answer.toJson());
    }
    return mapArray;
  }
}

List<Answer> decodeAnswerJsonArray(array){
  List<Answer> answers = [];

  if (array == null){
    return [];
  }
  for (var answer in array){
    answers.add(Answer.fromJson(answer));
  }
  return answers;
}

List<String> getStringAnswers(List<Answer> answers){
  List<String> parsedAnswers = [];
  for (Answer answer in answers){
    parsedAnswers.add(getAnswerWithoutInfo(answer.text));
  }
  return parsedAnswers;
}