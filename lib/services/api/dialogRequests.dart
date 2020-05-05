import 'dart:io';

import 'package:benkyou/models/UserDialog.dart';
import 'package:benkyou/services/rest.dart';

Future<UserDialog> getDialogRequest(int dialogId) async {
  HttpClientResponse response =  await getLocaleGetRequestResponse("/dialog/$dialogId");
  var dialog = await getJsonFromHttpResponse(response);
  return UserDialog.fromJson(dialog);
}