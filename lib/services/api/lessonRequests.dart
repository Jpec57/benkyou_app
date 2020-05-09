import 'dart:io';
import 'package:benkyou/models/Lesson.dart';
import 'package:benkyou/services/rest.dart';

Future<List<Lesson>> getLessonsRequest() async {
  HttpClientResponse cardResponse = await getLocaleGetRequestResponse("/lessons");
  var lessons = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)){
    print(lessons);
    return null;
  }
  List<Lesson> parsedCards = decodeLessonsJsonArray(lessons);
  return parsedCards;
}

Future<Lesson> getLessonRequest(int lessonId) async {
  HttpClientResponse cardResponse = await getLocaleGetRequestResponse("/lessons/$lessonId");
  var lesson = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)){
    print(lesson);
    return null;
  }
  return Lesson.fromJson(lesson);
}