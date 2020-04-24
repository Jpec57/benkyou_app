import 'dart:async';
import 'package:benkyou/screens/BrowseDeckPage/BrowseDeckPage.dart';
import 'package:benkyou/screens/CreateCardPage/CreateCardPage.dart';
import 'package:benkyou/screens/CreateCardPage/CreateCardPageArguments.dart';
import 'package:benkyou/screens/CreateUserPage/CreateUserPage.dart';
import 'package:benkyou/screens/ListCardPage/ListCardPage.dart';
import 'package:benkyou/screens/ListCardPage/ListCardPageArguments.dart';
import 'package:benkyou/screens/PreviewPublicDeckPage/PreviewPublicDeckPage.dart';
import 'package:benkyou/screens/PreviewPublicDeckPage/PreviewPublicDeckPageArguments.dart';
import 'package:benkyou/screens/ReviewPage/ReviewPage.dart';
import 'package:benkyou/screens/ReviewPage/ReviewPageArguments.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry/io_client.dart';
import 'screens/DeckPage/DeckPage.dart';
import 'screens/DeckPage/DeckPageArguments.dart';
import 'screens/HomePage/HomePage.dart';

import 'dsn.dart';

final SentryClient _sentry = new SentryClient(dsn: DSN);

const bool DEBUG = false;
const bool SENTRY = true;

void main() {
  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (DEBUG) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  runZoned(
        () =>
        runApp(MaterialApp(
          title: 'Benkyou',
          navigatorKey: Get.key,
          theme: ThemeData(
            primaryColor: Color(COLOR_DARK_BLUE),
          ),
          initialRoute: HomePage.routeName,
          onGenerateRoute: (settings) {
            if (settings.name == DeckPage.routeName) {
              final DeckPageArguments args = settings.arguments;

              return MaterialPageRoute(
                builder: (context) {
                  return DeckPage(
                    id: args.id,
                  );
                },
              );
            }
            if (settings.name == ReviewPage.routeName) {
              final ReviewPageArguments args = settings.arguments;
              return MaterialPageRoute(
                builder: (context) {
                  return ReviewPage(
                    cards: args.cards,
                  );
                },
              );
            }

            if (settings.name == CreateCardPage.routeName) {
              final CreateCardPageArguments args = settings.arguments;
              return MaterialPageRoute(
                builder: (context) {
                  return CreateCardPage(
                    deckId: args.deckId,
                  );
                },
              );
            }

            if (settings.name == ListCardPage.routeName) {
              final ListCardPageArguments args = settings.arguments;
              return MaterialPageRoute(
                builder: (context) {
                  return ListCardPage(
                    deckId: args.deckId,
                  );
                },
              );
            }

            if (settings.name == PreviewPublicDeckPage.routeName) {
              final PreviewPublicDeckPageArguments args = settings.arguments;
              return MaterialPageRoute(
                builder: (context) {
                  return PreviewPublicDeckPage(
                    deckId: args.deckId,
                  );
                },
              );
            }
            assert(false, 'Need to implement ${settings.name}');
            return null;
          },
          routes: {
            HomePage.routeName: (context) => HomePage(),
            CreateUserPage.routeName: (context) => CreateUserPage(),
            BrowseDeckPage.routeName: (context) => BrowseDeckPage(),
          },)
        ),
    onError: (Object error, StackTrace stackTrace) {
      try {
        if (SENTRY){
          _sentry.captureException(
            exception: error,
            stackTrace: stackTrace,
          );
          print('Error sent to sentry.io: $error');
        } else {
          print(error);
        }
      } catch (e) {
        print('Sending report to sentry.io failed: $e');
        print('Original error: $error');
      }
    },
  );
}