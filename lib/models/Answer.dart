class Answer{
  int id;
  String text;
  int type;

  Answer.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'],
        type = json['type']
  ;
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