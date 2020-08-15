import 'package:benkyou/models/Kanji.dart';
import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/screens/DrawPage/DrawPage.dart';
import 'package:benkyou/screens/Grammar/GrammarHomePage.dart';
import 'package:benkyou/screens/Grammar/GrammarReviewArguments.dart';
import 'package:benkyou/screens/Grammar/GrammarReviewPage.dart';
import 'package:benkyou/screens/LessonHomePage/LessonHomePage.dart';
import 'package:benkyou/screens/ReviewPage/ReviewPage.dart';
import 'package:benkyou/screens/ReviewPage/ReviewPageArguments.dart';
import 'package:benkyou/screens/ThemePages/ThemeLearningHomePage.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/services/api/kanjiRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/utils/utils.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:benkyou/widgets/NotificationWidget.dart';
import 'package:flutter/material.dart';

class SectionContainer extends StatelessWidget {
  final Color color;
  final Widget child;

  const SectionContainer({Key key, @required this.color, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          color: color,
          child: child,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<UserCard>> _vocabFuture;
  Future<List<UserCard>> _grammarFuture;
  Future<Kanji> _kanjiFuture;

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void reload() {
    _vocabFuture = getReviewCards();
    _grammarFuture = getGrammarReviewCards();
    _kanjiFuture = getRandomKanji();
  }

  Widget _renderBigIcon(IconData icon) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Icon(icon, color: Colors.white, size: constraints.biggest.height),
        );
      },
    );
  }

  Widget _renderDefaultSection(String text, IconData icon) {
    return SectionContainer(
      color: Color(COLOR_ORANGE),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: _renderBigIcon(icon)),
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0, top: 8),
              child: Text(
                text,
                style: Theme.of(context).textTheme.headline5,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _renderVocabSectionWithNotif(String text) {
    IconData icon = Icons.chrome_reader_mode;
    Widget defaultWidget = InkWell(
      splashColor: Colors.grey,
      onTap: () {
        Navigator.of(context).pushNamed(DeckHomePage.routeName);
      },
      child: _renderDefaultSection(text, icon),
    );
    return Expanded(
      child: FutureBuilder(
        future: _vocabFuture,
        builder:
            (BuildContext context, AsyncSnapshot<List<UserCard>> wordSnapshot) {
          switch (wordSnapshot.connectionState) {
            case ConnectionState.waiting:
              return SectionContainer(
                color: Color(COLOR_ORANGE),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            case ConnectionState.done:
              if (!wordSnapshot.hasData) {
                return defaultWidget;
              }
              return Stack(children: [
                Positioned.fill(
                  child: InkWell(
                      splashColor: Colors.grey,
                      onTap: () {
                        if (wordSnapshot.hasData &&
                            wordSnapshot.data.length > 0) {
                          Navigator.of(context).pushNamed(ReviewPage.routeName,
                              arguments: ReviewPageArguments(
                                  cards: wordSnapshot.data,
                                  isFromHomePage: true));
                        }
                      },
                      child: SectionContainer(
                          color: Color(COLOR_ORANGE),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(child: _renderBigIcon(icon)),
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 5.0, top: 8),
                                child: Text(
                                  text,
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                              )
                            ],
                          ))),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child:
                      NotificationWidget(text: "${wordSnapshot.data.length}"),
                )
              ]);
            case ConnectionState.none:
              return defaultWidget;
            default:
              return defaultWidget;
          }
        },
      ),
    );
  }

  Widget _renderGrammarSectionWithNotif(String text) {
    IconData icon = Icons.layers;
    Widget defaultWidget = InkWell(
      splashColor: Colors.grey,
      onTap: () {
        Navigator.of(context).pushNamed(GrammarHomePage.routeName);
      },
      child: _renderDefaultSection(text, icon),
    );
    return Expanded(
      child: FutureBuilder(
        future: _grammarFuture,
        builder:
            (BuildContext context, AsyncSnapshot<List<UserCard>> grammarSnap) {
          switch (grammarSnap.connectionState) {
            case ConnectionState.waiting:
              return SectionContainer(
                color: Color(COLOR_ORANGE),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            case ConnectionState.done:
              if (!grammarSnap.hasData) {
                return defaultWidget;
              }
              return Stack(children: [
                Positioned.fill(
                  child: InkWell(
                      splashColor: Colors.grey,
                      onTap: () {
                        if (grammarSnap.hasData &&
                            grammarSnap.data.length > 0) {
                          Navigator.of(context).pushNamed(
                              GrammarReviewPage.routeName,
                              arguments: GrammarReviewArguments(
                                  reviewCards: grammarSnap.data,
                                  isFromHomePage: true));
                        }
                      },
                      child: SectionContainer(
                          color: Color(COLOR_ORANGE),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(child: _renderBigIcon(icon)),
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 5.0, top: 8),
                                child: Text(
                                  text,
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                              )
                            ],
                          ))),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: NotificationWidget(text: "${grammarSnap.data.length}"),
                )
              ]);
            case ConnectionState.none:
              return defaultWidget;
            default:
              return defaultWidget;
          }
        },
      ),
    );
  }

  Widget _renderLessonSection() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(LessonHomePage.routeName);
      },
      child: _renderBigIcon(Icons.assignment),
    );
  }

  Widget _renderThemeSection() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(ThemeLearningHomePage.routeName);
      },
      child: _renderBigIcon(Icons.flight_takeoff),
    );
  }

  Widget _renderAllSection() {
    return GestureDetector(
      onTap: () {
        showNotImplementedSnack();
      },
      child: _renderBigIcon(Icons.all_inclusive),
    );
  }

  Widget _renderDrawSection() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(DrawPage.routeName);
      },
      child: _renderBigIcon(Icons.border_color),
    );
  }

  Widget _renderSection(Widget sectionWidget, String text,
      {Color color = const Color(COLOR_ORANGE)}) {
    return SectionContainer(
      color: color,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: sectionWidget),
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0, top: 8),
              child: Text(
                text,
                style: Theme.of(context).textTheme.headline5,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _renderKanjiLine(String title, String text) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: '',
        style: Theme.of(context).textTheme.bodyText2,
        children: <TextSpan>[
          TextSpan(
              text: title,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          TextSpan(text: text, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  String formatStringArray(List<String> list) {
    if (list == null || list.isEmpty) {
      return "";
    }
    int length = list.length;
    if (length > 1) {
      return list.join(", ");
    }
    return list[0];
  }

  Widget _renderRandomKanjiWidget() {
    Widget defaultWidget = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.25),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: 15, bottom: 15),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black45, width: 3),
                      borderRadius: BorderRadius.circular(25)),
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return Center(
                        child: Text(
                          "力",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: constraints.biggest.height / 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
              textAlign: TextAlign.justify,
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
            ),
          )
        ],
      ),
    );
    return Expanded(
      flex: 5,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            color: Color(COLOR_ORANGE),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 20, left: 25, right: 25),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      "Daily kanji",
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ),
                  FutureBuilder(
                    future: _kanjiFuture,
                    builder:
                        (BuildContext context, AsyncSnapshot<Kanji> kanjiSnap) {
                      switch (kanjiSnap.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.done:
                          if (!kanjiSnap.hasData) {
                            return defaultWidget;
                          }
                          Kanji kanji = kanjiSnap.data;
                          String readings = formatStringArray(kanji.readings);
                          String meanings = formatStringArray(kanji.meanings);
                          return Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minHeight:
                                            MediaQuery.of(context).size.height *
                                                0.25),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30,
                                          right: 30,
                                          top: 15,
                                          bottom: 15),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black45,
                                                width: 3),
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: LayoutBuilder(
                                          builder: (BuildContext context,
                                              BoxConstraints constraints) {
                                            return Center(
                                              child: Text(
                                                kanji.symbol,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: constraints
                                                            .biggest.height /
                                                        2),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                _renderKanjiLine('Readings: ', readings),
                                _renderKanjiLine('Meanings: ', meanings),
                                _renderKanjiLine('Jouyou Level: ',
                                    '${kanji.jouyouLevel != null && kanji.jouyouLevel != -1 ? kanji.jouyouLevel : "Unknown"}'),
                                _renderKanjiLine('JLPT level: ',
                                    '${kanji.jlptLevel != null && kanji.jlptLevel != -1 ? kanji.jlptLevel : "Unknown"}'),
                              ],
                            ),
                          );
                        case ConnectionState.none:
                          return Center(
                              child: Text(LocalizationWidget.of(context)
                                  .getLocalizeValue('no_internet_connection')));
                        default:
                          return defaultWidget;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: MainDrawer(),
      body: Container(
        color: Color(COLOR_ANTRACITA),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _renderRandomKanjiWidget(),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 35, right: 35, bottom: 10),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _renderVocabSectionWithNotif(
                              LocalizationWidget.of(context)
                                  .getLocalizeValue("vocabulary")),
                          _renderGrammarSectionWithNotif(
                              LocalizationWidget.of(context)
                                  .getLocalizeValue("grammar")),
                          Expanded(
                            child: _renderSection(
                                _renderLessonSection(),
                                LocalizationWidget.of(context)
                                    .getLocalizeValue("lessons")),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _renderSection(
                                _renderThemeSection(),
                                LocalizationWidget.of(context)
                                    .getLocalizeValue("themes")),
                          ),
                          Expanded(
                            child: _renderSection(
                                _renderAllSection(),
                                LocalizationWidget.of(context)
                                    .getLocalizeValue("all_reviews"),
                                color: Color(COLOR_MID_DARK_GREY)),
                          ),
                          Expanded(
                            child: _renderSection(
                                _renderDrawSection(),
                                LocalizationWidget.of(context)
                                    .getLocalizeValue("draw")),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
//            Expanded(
//              flex: 3,
//              child: Padding(
//                padding: const EdgeInsets.only(
//                    top: 10, left: 35, right: 35, bottom: 10),
//                child: GridView.count(
//                    shrinkWrap: true,
//                    physics: NeverScrollableScrollPhysics(),
//                    mainAxisSpacing: 20,
//                    crossAxisSpacing: 20,
//                    childAspectRatio: 1,
//                    crossAxisCount: 3,
//                    key: ValueKey('section-grid'),
//                    children: List.generate(6, (index) {
//                      return _renderSection();
//                    })),
//              ),
//            ),
          ],
        ),
      ),
    );
  }
}
