import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

handleErrors(int statusCode, jsonCodec){
  if (300 > statusCode && statusCode >= 200){
    return jsonCodec;
  }
  //TODO log correctly
  print(jsonCodec);
  return null;
}

makeLocaleGetRequest(String uri) async {
  HttpClient client = new HttpClient();
  client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  String url = 'https://10.0.2.2:8000$uri';
  HttpClientRequest request = await client.getUrl(Uri.parse(url));

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String apiToken = sharedPreferences.get('apiToken');
  if (apiToken != null){
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiToken');
  }
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
  HttpClientResponse response = await request.close();
  String reply = await response.transform(utf8.decoder).join();
  var jsonCodec = json.decode(reply);
  print(jsonCodec);
  return handleErrors(response.statusCode, jsonCodec);
}

makeLocalePostRequest(String uri, Map body) async{
  HttpClient client = new HttpClient();
  client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  String url = 'https://10.0.2.2:8000$uri';
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String apiToken = sharedPreferences.get('apiToken');

  HttpClientRequest request = await client.postUrl(Uri.parse(url));
  if (apiToken != null){
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiToken');
  }
  //  request.headers.set(HttpHeaders.authorizationHeader, 'Bearer ADMIN_TOKEN_DEBUG');
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
  List<int> parsedBody = utf8.encode(json.encode(body));
  request.headers.set(HttpHeaders.contentLengthHeader, parsedBody.length);
  request.add(parsedBody);
  HttpClientResponse response = await request.close();
  String reply = await response.transform(utf8.decoder).join();
  if (response.statusCode > 299){
    print(reply);
    return null;
  }
  var jsonCodec = json.decode(reply);
  print(jsonCodec);
  return jsonCodec;
}