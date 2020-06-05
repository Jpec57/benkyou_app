import 'package:benkyou/models/DeckTheme.dart';
import 'package:benkyou/screens/DialogPage/InDialogPageArguments.dart';
import 'package:benkyou/screens/ThemePages/Listening/ThemeListeningPartPage.dart';
import 'package:benkyou/screens/ThemePages/Listening/ThemeListeningPartPageArguments.dart';
import 'package:benkyou/screens/ThemePages/Word/ThemeTinderWordPage.dart';
import 'package:benkyou/screens/ThemePages/Word/ThemeTinderWordPageArguments.dart';
import 'package:benkyou/services/api/themeRequests.dart';
import 'package:benkyou/transitions/ScaleRoute.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeLearningHomePage extends StatefulWidget {
  static const routeName = '/themes';

  @override
  State<StatefulWidget> createState() => ThemeLearningHomePageState();
}

class ThemeLearningHomePageState extends State<ThemeLearningHomePage> {
  Future<List<DeckTheme>> _themes;

  void setThemes(){
    _themes = getThemesRequest();
  }

  @override
  void initState() {
    super.initState();
    setThemes();
  }

  Widget _renderThemes(DeckTheme theme){
    double side = MediaQuery.of(context).size.width * 0.4;
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(ScaleRoute(page: ThemeTinderWordPage(theme: theme,)));
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/imgs/japan.png"),
                fit: BoxFit.cover
              )
            ),
            height: side,
            width: side,
            child: Center(child: Text(theme.name.toUpperCase(), style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(2.0, 2.0),
                  blurRadius: 3.0,
                  color: Colors.grey,
                ),
              ],
            ),)),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a theme'),
      ),
      body: FutureBuilder(
        future: _themes,
        builder: (BuildContext context, AsyncSnapshot<List<DeckTheme>> themeSnapshot) {
          switch (themeSnapshot.connectionState){
            case ConnectionState.waiting:
              return Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('loading')),);
            case ConnectionState.done:
              List<DeckTheme> themes = themeSnapshot.data;
              if (themes != null && themes.length > 0){
                return GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  children: List.generate(themes.length, (index) => _renderThemes(themes[index])),);
              }
              return Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('empty')),);
            default:
              return Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('generic_error')),)
              ;
          }
        },
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}