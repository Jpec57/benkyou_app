import 'dart:convert';
import 'dart:io';

makeLocaleGetRequest(String uri) async {
  HttpClient client = new HttpClient();
  client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  String url = 'https://10.0.2.2:8000$uri';
  HttpClientRequest request = await client.getUrl(Uri.parse(url));
  request.headers.set(HttpHeaders.authorizationHeader, 'Bearer ADMIN_TOKEN_DEBUG');
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
  HttpClientResponse response = await request.close();
  String reply = await response.transform(utf8.decoder).join();
  var jsonCodec = json.decode(reply);
  print("CALL API $uri");
//  print(jsonCodec);
  return jsonCodec;
}

makeLocalePostRequest(String uri, Map body) async{
  HttpClient client = new HttpClient();
  client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  String url = 'https://10.0.2.2:8000$uri';

  HttpClientRequest request = await client.getUrl(Uri.parse(url));
  request.headers.set(HttpHeaders.authorizationHeader, 'Bearer ADMIN_TOKEN_DEBUG');
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
  request.add(utf8.encode(json.encode(body)));
  HttpClientResponse response = await request.close();
  String reply = await response.transform(utf8.decoder).join();
  var jsonCodec = json.decode(reply);
  print(jsonCodec);
  return jsonCodec;
}