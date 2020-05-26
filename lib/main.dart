import 'dart:async';
import 'package:benkyou/screens/BrowseDeckPage/BrowseDeckPage.dart';
import 'package:benkyou/screens/CreateCardPage/CreateCardPage.dart';
import 'package:benkyou/screens/CreateCardPage/CreateCardPageArguments.dart';
import 'package:benkyou/screens/CreateUserPage/CreateUserPage.dart';
import 'package:benkyou/screens/DialogPage/DialogPage.dart';
import 'package:benkyou/screens/DialogPage/InDialogPage.dart';
import 'package:benkyou/screens/DialogPage/InDialogPageArguments.dart';
import 'package:benkyou/screens/GrammarReviewPage/GrammarReviewPage.dart';
import 'package:benkyou/screens/HomePage/HomePage.dart';
import 'package:benkyou/screens/LessonHomePage/LessonHomePage.dart';
import 'package:benkyou/screens/LessonHomePage/LessonPage.dart';
import 'package:benkyou/screens/LessonHomePage/LessonPageArguments.dart';
import 'package:benkyou/screens/ListCardPage/ListCardPage.dart';
import 'package:benkyou/screens/ListCardPage/ListCardPageArguments.dart';
import 'package:benkyou/screens/ListDialogs/ListDialogPage.dart';
import 'package:benkyou/screens/LoginPage/LoginPage.dart';
import 'package:benkyou/screens/ModifyCardPage/ModifyCardPage.dart';
import 'package:benkyou/screens/ModifyCardPage/ModifyCardPageArguments.dart';
import 'package:benkyou/screens/PreviewPublicDeckPage/PreviewPublicDeckPage.dart';
import 'package:benkyou/screens/PreviewPublicDeckPage/PreviewPublicDeckPageArguments.dart';
import 'package:benkyou/screens/ProfilePage/ProfilePage.dart';
import 'package:benkyou/screens/ProfilePage/ProfilePageArguments.dart';
import 'package:benkyou/screens/ReviewPage/ReviewPage.dart';
import 'package:benkyou/screens/ReviewPage/ReviewPageArguments.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:sentry/io_client.dart';
import 'screens/DeckPage/DeckPage.dart';
import 'screens/DeckPage/DeckPageArguments.dart';
import 'screens/DeckHomePage/DeckHomePage.dart';

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
          localizationsDelegates: [
            MyLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale(EN_LOCALE),
            const Locale(FR_LOCALE),
            const Locale(JAP_LOCALE),
          ],
          title: 'Benkyou',
          navigatorKey: Get.key,
          theme: ThemeData(
            primaryColor: Color(COLOR_DARK_BLUE),
          ),
          initialRoute: DeckHomePage.routeName,
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

            if (settings.name == LessonPage.routeName) {
              final LessonPageArguments args = settings.arguments;
              return MaterialPageRoute(
                builder: (context) {
                  return LessonPage(
                    lessonId: args.lessonId,
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

            if (settings.name == ModifyCardPage.routeName) {
              final ModifyCardPageArguments args = settings.arguments;
              return MaterialPageRoute(
                builder: (context) {
                  return ModifyCardPage(
                    userCard: args.userCard,
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

            if (settings.name == ProfilePage.routeName) {
              final ProfilePageArguments args = settings.arguments;
              return MaterialPageRoute(
                builder: (context) {
                  return ProfilePage(
                    userId: args != null ? args.userId : null,
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

            if (settings.name == InDialogPage.routeName) {
              final InDialogPageArguments args = settings.arguments;
              return MaterialPageRoute(
                builder: (context) {
                  return InDialogPage(
                    dialogId: args.dialogId,
                  );
                },
              );
            }
            assert(false, 'Need to implement ${settings.name}');
            return null;
          },
          routes: {
            DeckHomePage.routeName: (context) => DeckHomePage(),
            GrammarReviewPage.routeName: (context) => GrammarReviewPage(),
            LoginPage.routeName: (context) => LoginPage(),
            LessonHomePage.routeName: (context) => LessonHomePage(),
            HomePage.routeName: (context) => HomePage(),
//            InDialogPage.routeName: (context) => InDialogPage(),
            ListDialogPage.routeName: (context) => ListDialogPage(),
            DialogPage.routeName: (context) => DialogPage(),
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