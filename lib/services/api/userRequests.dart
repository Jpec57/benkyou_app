import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../rest.dart';

Future<bool> loginRequest(String username, String password) async {
  Map map = new Map();
  map.putIfAbsent("email", () => username);
  map.putIfAbsent("password", () => password);
  var token = await makeLocalePostRequest("/login", map);
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString('apiToken', token["token"]);
  sharedPreferences.setString('username', token["user"]["username"]);
  sharedPreferences.setInt('userId', token["user"]["id"]);
  sharedPreferences.setString('email', token["user"]["email"]);
  return true;
}

Future<HttpClientResponse> registerRequest(String email, String username, String password) async {
  Map map = new Map();
  map.putIfAbsent("username", () => username);
  map.putIfAbsent("email", () => email);
  map.putIfAbsent("password", () => password);
  return await getLocalePostRequestResponse("/register", map);
}


Future<bool> logoutRequest() async {
  await makeLocaleGetRequest("/logout");
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.remove('apiToken');
  sharedPreferences.remove('username');
  sharedPreferences.remove('userId');
  sharedPreferences.remove('email');
  return true;
}

