import 'dart:io';
import 'package:benkyou/models/DeckTheme.dart';
import 'package:benkyou/services/rest.dart';

Future<List<DeckTheme>> getThemesRequest() async {
  HttpClientResponse response = await getLocaleGetRequestResponse("/themes");
  var entities = await getJsonFromHttpResponse(response);
  print(entities);
  if (!isRequestValid(response.statusCode)){
    print(entities);
    return null;
  }
  List<DeckTheme> parsedEntities = decodeDeckThemesJsonArray(entities);
  print(parsedEntities);
  return parsedEntities;
}