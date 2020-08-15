import 'dart:io';

import 'package:benkyou/models/Kanji.dart';
import 'package:benkyou/services/rest.dart';

Future<Kanji> getRandomKanji() async {
  HttpClientResponse cardResponse =
      await getLocaleGetRequestResponse("/kanji/random");
  var json = await getJsonFromHttpResponse(cardResponse);
  if (!isRequestValid(cardResponse.statusCode)) {
    print("getRandomKanji ${json.toString()}");
    return null;
  }
  return Kanji.fromJson(json[0]);
}
