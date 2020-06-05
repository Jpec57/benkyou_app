import 'dart:convert';
import 'dart:io';
import 'package:benkyou/main.dart';
import 'package:benkyou/services/api/userRequests.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<HttpClientResponse> handleGenericErrors(HttpClientResponse response) async {
  int statusCode = response.statusCode;
  //Token expired
  if (statusCode == 401){
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.get('apiToken') != null){
      sharedPreferences.remove('apiToken');
      Get.snackbar('API Token expired', 'Your token has expired. Please log in again.', snackPosition: SnackPosition.BOTTOM);
    }
    await logoutRequest();
  }
  return response;
}

bool isRequestValid(int statusCode){
  return (statusCode >= 200 && statusCode < 300);
}

getJsonFromHttpResponse(HttpClientResponse response) async{
  String reply = await response.transform(utf8.decoder).join();
  print(reply);
  return json.decode(reply);
}

Future<HttpClientResponse> getRemoteGetRequestResponse(String url, {canHandleGenericErrors = true}) async {
  HttpClient client = new HttpClient();
  client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  HttpClientRequest request = await client.getUrl(Uri.parse(url));
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
  HttpClientResponse response = await request.close();
  if (canHandleGenericErrors){
    response = await handleGenericErrors(response);
  }
  return response;
}

Future<HttpClientResponse> getLocaleGetRequestResponse(String uri, {canHandleGenericErrors = true}) async {
  HttpClient client = new HttpClient();
  client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  String url;
  if (DEBUG){
    url = 'https://10.0.2.2:8000$uri';
  } else {
//    url = 'http://51.158.152.165:8000$uri';
    url = 'https://jpec.be/$uri';
  }
  HttpClientRequest request = await client.getUrl(Uri.parse(url));

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String apiToken = sharedPreferences.get('apiToken');
  if (apiToken != null){
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiToken');
  }
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
  HttpClientResponse response = await request.close();
  if (canHandleGenericErrors){
    response = await handleGenericErrors(response);
  }
  return response;
}

Future<HttpClientResponse> getLocalePostRequestResponse(String uri, Map body, {canHandleGenericErrors = true}) async{
  HttpClient client = new HttpClient();
  client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  String url;
  if (DEBUG){
    url = 'https://10.0.2.2:8000$uri';
  } else {
//    url = 'http://51.158.152.165:8000$uri';
    url = 'https://jpec.be/$uri';
  }
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String apiToken = sharedPreferences.get('apiToken');

  HttpClientRequest request = await client.postUrl(Uri.parse(url));
  if (apiToken != null){
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiToken');
  }
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
  List<int> parsedBody = utf8.encode(json.encode(body));
  request.headers.set(HttpHeaders.contentLengthHeader, parsedBody.length);
  request.add(parsedBody);
  HttpClientResponse response = await request.close();
  if (canHandleGenericErrors){
    response = await handleGenericErrors(response);
  }
  return response;
}

Future<HttpClientResponse> getLocaleDeleteRequestResponse(String uri, {canHandleGenericErrors = true}) async {
  HttpClient client = new HttpClient();
  client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  String url;
  if (DEBUG){
    url = 'https://10.0.2.2:8000$uri';
  } else {
//    url = 'http://51.158.152.165:8000$uri';
    url = 'https://jpec.be/$uri';
  }
  HttpClientRequest request = await client.deleteUrl(Uri.parse(url));

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String apiToken = sharedPreferences.get('apiToken');
  if (apiToken != null){
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiToken');
  }
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
  HttpClientResponse response = await request.close();
  if (canHandleGenericErrors){
    response = await handleGenericErrors(response);
  }
  return response;
}