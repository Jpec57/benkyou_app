import 'dart:io';

import 'package:benkyou/models/Sentence.dart';
import 'package:benkyou/services/rest.dart';

Future<List<Sentence>> getRandomSentencesRequest(int number) async {
  HttpClientResponse response =
      await getLocaleGetRequestResponse("/sentences/random/$number");
  var entities = await getJsonFromHttpResponse(response);
  if (!isRequestValid(response.statusCode)) {
    print(entities);
    return null;
  }
  List<Sentence> parsedEntities = decodeSentencesJsonArray(entities);
  return parsedEntities;
}

Future<List<Sentence>> getRandomThemeSentencesRequest(
    int themeId, int number) async {
  HttpClientResponse response = await getLocaleGetRequestResponse(
      "/themes/$themeId/sentences/random/$number");
  var entities = await getJsonFromHttpResponse(response);
  print(entities);
  if (!isRequestValid(response.statusCode)) {
    print(entities);
    return null;
  }
  List<Sentence> parsedEntities = decodeSentencesJsonArray(entities);
  print(parsedEntities);
  return parsedEntities;
}

Future<List<Sentence>> searchSentencesRequest(
    String searchText, int maxResult) async {
  Map map = new Map();
  map.putIfAbsent('searchText', () => searchText);
  map.putIfAbsent('maxResult', () => maxResult);
  HttpClientResponse response =
      await getLocalePostRequestResponse("/sentences/search", map);
  var entities = await getJsonFromHttpResponse(response);
  print(entities);
  if (!isRequestValid(response.statusCode)) {
    print(entities);
    return null;
  }
  List<Sentence> parsedEntities = decodeSentencesJsonArray(entities);
  print(parsedEntities);
  return parsedEntities;
}
