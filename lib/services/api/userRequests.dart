import 'dart:convert';
import 'dart:io';

import 'package:benkyou/models/User.dart';
import 'package:benkyou/screens/LoginPage/LoginPage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../rest.dart';

Future<bool> loginRequest(String username, String password) async {
  Map map = new Map();
  map.putIfAbsent("email", () => username);
  map.putIfAbsent("password", () => password);
  HttpClientResponse tokenResponse = await getLocalePostRequestResponse("/login", map);
  print(tokenResponse.statusCode);
  if (!isRequestValid(tokenResponse.statusCode)){
    print(tokenResponse.statusCode);
    if (tokenResponse.statusCode == 400){
      Get.snackbar('Incorrect credentials', 'The username or password is incorrect.', snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', 'An error occurred. Please contact the support for any help.', snackPosition: SnackPosition.BOTTOM);
    }
    String reply = await tokenResponse.transform(utf8.decoder).join();
    return false;
  }
  var token = await getJsonFromHttpResponse(tokenResponse);
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString('apiToken', token["token"]);
  sharedPreferences.setString('username', token["user"]["username"]);
  sharedPreferences.setInt('userId', token["user"]["id"]);
  sharedPreferences.setString('email', token["user"]["email"]);
  sharedPreferences.setString('previousUsername', username);
  return true;
}

Future<HttpClientResponse> registerRequest(String email, String username, String password) async {
  Map map = new Map();
  map.putIfAbsent("username", () => username);
  map.putIfAbsent("email", () => email);
  map.putIfAbsent("password", () => password);
  return await getLocalePostRequestResponse("/register", map);
}

Future<void> _resetSharedPreferences() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.remove('apiToken');
  sharedPreferences.remove('username');
  sharedPreferences.remove('userId');
  sharedPreferences.remove('email');
}

Future<bool> logoutRequest({bool shouldRedirect = false}) async {
  HttpClientResponse response = await getLocaleGetRequestResponse("/logout", canHandleGenericErrors: false);
  await _resetSharedPreferences();
  if (shouldRedirect){
    Get.to(LoginPage());
  }
  if (!isRequestValid(response.statusCode)){
    print(await getJsonFromHttpResponse(response));
    return false;
  }
  return true;
}

Future<User> getMyProfileRequest() async {
  HttpClientResponse response = await getLocaleGetRequestResponse("/my-profile", canHandleGenericErrors: true);
  if (!isRequestValid(response.statusCode)){
    print(await getJsonFromHttpResponse(response));
    return null;
  }
  var json = await getJsonFromHttpResponse(response);
  return User.fromJson(json);
}

Future<User> getUserRequest(int userId) async {
  HttpClientResponse response = await getLocaleGetRequestResponse("/users/$userId", canHandleGenericErrors: true);
  if (!isRequestValid(response.statusCode)){
    print(await getJsonFromHttpResponse(response));
    return null;
  }
  var json = await getJsonFromHttpResponse(response);
  return User.fromJson(json);
}