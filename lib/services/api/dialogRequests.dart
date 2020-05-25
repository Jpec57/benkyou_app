import 'dart:io';

import 'package:benkyou/models/UserDialog.dart';
import 'package:benkyou/services/rest.dart';

Future<UserDialog> getDialogRequest(int dialogId) async {
  HttpClientResponse response =  await getLocaleGetRequestResponse("/dialog/$dialogId");
  var dialog = await getJsonFromHttpResponse(response);
  return UserDialog.fromJson(dialog);
}

Future<List<UserDialog>> getDialogsRequest() async {
  HttpClientResponse response =  await getLocaleGetRequestResponse("/dialogs");
  List<dynamic> dialogs = await getJsonFromHttpResponse(response);
  List<UserDialog> parsedDialogs = [];
  print(response.statusCode);
  for (Map<String, dynamic> dialog in dialogs){
    parsedDialogs.add(UserDialog.fromJson(dialog));
  }
  return parsedDialogs;
}