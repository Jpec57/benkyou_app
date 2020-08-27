import 'dart:async';

import 'package:benkyou/screens/BrowseDeckPage/BrowseDeckPage.dart';
import 'package:benkyou/screens/CreateCardPage/CreateCardPage.dart';
import 'package:benkyou/screens/CreateCardPage/CreateCardPageArguments.dart';
import 'package:benkyou/screens/CreateUserPage/CreateUserPage.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/screens/DialogPage/DialogPage.dart';
import 'package:benkyou/screens/DialogPage/InDialogPage.dart';
import 'package:benkyou/screens/DialogPage/InDialogPageArguments.dart';
import 'package:benkyou/screens/DrawPage/DrawPage.dart';
import 'package:benkyou/screens/Grammar/CreateGrammarCardArguments.dart';
import 'package:benkyou/screens/Grammar/CreateGrammarPage.dart';
import 'package:benkyou/screens/Grammar/GrammarDeckPage.dart';
import 'package:benkyou/screens/Grammar/GrammarDeckPageArguments.dart';
import 'package:benkyou/screens/Grammar/GrammarHomePage.dart';
import 'package:benkyou/screens/Grammar/GrammarReviewArguments.dart';
import 'package:benkyou/screens/Grammar/GrammarReviewPage.dart';
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
import 'package:benkyou/screens/TestPage.dart';
import 'package:benkyou/screens/ThemePages/Listening/ThemeListeningPartPage.dart';
import 'package:benkyou/screens/ThemePages/Listening/ThemeListeningPartPageArguments.dart';
import 'package:benkyou/screens/ThemePages/ThemeLearningHomePage.dart';
import 'package:benkyou/screens/ThemePages/Word/ThemeTinderWordPage.dart';
import 'package:benkyou/screens/ThemePages/Word/ThemeTinderWordPageArguments.dart';
import 'package:benkyou/screens/ThemePages/Writing/ThemeWritingPartPage.dart';
import 'package:benkyou/screens/ThemePages/Writing/ThemeWritingPartPageArguments.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:sentry/io_client.dart';

import 'dsn.dart';
import 'screens/DeckPage/DeckPage.dart';
import 'screens/DeckPage/DeckPageArguments.dart';

final SentryClient _sentry = new SentryClient(dsn: DSN);

const bool DEBUG = false;
const bool SENTRY = true;

class App extends StatelessWidget {
  final Widget home;

  const App({Key key, @required this.home}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        textTheme: TextTheme(
          headline3: TextStyle(
              fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600),
          headline4: TextStyle(fontSize: 22, color: Colors.white),
          headline5: TextStyle(fontSize: 14, color: Colors.white),
          headline6: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      home: home,
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
                isFromHomePage: args.isFromHomePage,
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
        if (settings.name == ThemeTinderWordPage.routeName) {
          final ThemeTinderWordPageArguments args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) {
              return ThemeTinderWordPage(
                theme: args.theme,
              );
            },
          );
        }
        if (settings.name == CreateGrammarCardPage.routeName) {
          final CreateGrammarCardArguments args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) {
              return CreateGrammarCardPage(
                deckId: args.deckId,
              );
            },
          );
        }
        if (settings.name == ThemeListeningPartPage.routeName) {
          final ThemeListeningPartPageArguments args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) {
              return ThemeListeningPartPage(
                chosenTheme: args.chosenTheme,
              );
            },
          );
        }
        if (settings.name == ThemeWritingPartPage.routeName) {
          final ThemeWritingPartPageArguments args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) {
              return ThemeWritingPartPage(
                theme: args.theme,
              );
            },
          );
        }
        if (settings.name == GrammarDeckPage.routeName) {
          final GrammarDeckPageArguments args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) {
              return GrammarDeckPage(
                deckId: args.deckId,
              );
            },
          );
        }

        if (settings.name == GrammarReviewPage.routeName) {
          final GrammarReviewArguments args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) {
              return GrammarReviewPage(
                deckId: args.deckId,
                cards: args.reviewCards,
                isFromHomePage: args.isFromHomePage,
              );
            },
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
      routes: {
        LoginPage.routeName: (context) => LoginPage(),
        LessonHomePage.routeName: (context) => LessonHomePage(),
        ThemeLearningHomePage.routeName: (context) => ThemeLearningHomePage(),
//            InDialogPage.routeName: (context) => InDialogPage(),
        ListDialogPage.routeName: (context) => ListDialogPage(),
        GrammarHomePage.routeName: (context) => GrammarHomePage(),
        DialogPage.routeName: (context) => DialogPage(),
        CreateUserPage.routeName: (context) => CreateUserPage(),
        BrowseDeckPage.routeName: (context) => BrowseDeckPage(),
        DeckHomePage.routeName: (context) => DeckHomePage(),
        DrawPage.routeName: (context) => DrawPage(),
        HomePage.routeName: (context) => HomePage(),
        TestPage.routeName: (context) => TestPage(),
      },
    );
  }
}

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
    () => runApp(App(
//          home: ThemeTinderWordPage(theme: new DeckTheme.fromJson({"id":21,"name":"Work","backgroundImg": null,"deck":{"id":59}})),
      home: HomePage(),
//      home: CreateCardPage(
//        deckId: 127,
//      ),
    )),
    onError: (Object error, StackTrace stackTrace) {
      try {
        if (SENTRY) {
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
