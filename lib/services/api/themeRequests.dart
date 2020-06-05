import 'dart:io';
import 'package:benkyou/models/DeckTheme.dart';
import 'package:benkyou/services/rest.dart';

Future<List<DeckTheme>> getThemesRequest() async {
  HttpClientResponse response = await getLocaleGetRequestResponse("/themes");
  var entities = await getJsonFromHttpResponse(response);
  if (!isRequestValid(response.statusCode)){
    return null;
  }
  List<DeckTheme> parsedEntities = decodeDeckThemesJsonArray(entities);
  return parsedEntities;
}