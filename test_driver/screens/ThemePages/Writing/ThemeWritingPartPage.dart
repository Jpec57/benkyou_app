import 'package:benkyou/models/DeckTheme.dart';
import 'package:benkyou/models/Sentence.dart';
import 'package:benkyou/screens/ThemePages/Writing/ThemeWritingPartPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:benkyou/main.dart' as app;

void main() {
  enableFlutterDriverExtension();

  runApp(
      app.App(
        home: ThemeWritingPartPage(
          theme: new DeckTheme.fromJson({"id":21,"name":"Work","backgroundImg": null,"deck":{"id":59}})
      ),)
  );
}