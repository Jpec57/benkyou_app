import 'dart:math';

import 'package:benkyou/models/DeckCard.dart';
import 'package:benkyou/models/DeckTheme.dart';
import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/screens/ThemePages/Listening/ThemeListeningPartPageArguments.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/ThemeTransitionDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Listening/ThemeListeningPartPage.dart';

class ThemeTinderWordPage extends StatefulWidget {
  static const routeName = '/themes/words';
  final DeckTheme theme;

  const ThemeTinderWordPage({Key key, this.theme}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeTinderWordPageState();
}

class ThemeTinderWordPageState extends State<ThemeTinderWordPage> with TickerProviderStateMixin{
  Future<List<DeckCard>> _cards;
  List<DeckCard> _fetchedCards;
  int _currentIndex;
  int _nbRemainingCards = 0;
  int _nbSuccess = 0;
  int _nbErrors = 0;
  int _initNbCards = 0;
  double _currentProgressValue = 0;
  bool _isAnswerVisible = false;
  bool isCorrect = false;
  AnimationController _animationController;



  void initCards() async {
    _cards = getRandomThemeCardsInDeck(widget.theme.deck.id, 2);
    _fetchedCards = await _cards;
    _nbRemainingCards = _fetchedCards.length;
    _currentIndex = _nbRemainingCards - 1;
    _initNbCards = _nbRemainingCards;
  }

  @override
  void initState() {
    super.initState();
    initCards();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      showDialog(context: context, builder: (BuildContext context) => ThemeTransitionDialog(name: 'Vocabulary'));
      Future.delayed(Duration(seconds: 3), (){
        Navigator.of(context).pop();
      });
    });
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

  }

  void _getToNextWord(bool isSuccess){
    if (isSuccess){
      _nbSuccess++;
      _currentProgressValue = _nbSuccess / _initNbCards;
      if (_currentIndex - 1 >= 0){
        _currentIndex--;
        _nbRemainingCards--;
        _fetchedCards.removeLast();
      } else {
        Navigator.of(context).pushNamed(ThemeListeningPartPage.routeName, arguments: ThemeListeningPartPageArguments(widget.theme));
      }
    } else {
      _nbErrors++;
      Random random = new Random();
      _fetchedCards.shuffle(random);
    }
    _animationController.reset();

    setState(() {
      _isAnswerVisible = false;
    });
  }

  List<Widget> _renderTinderCardSolutionPart(DeckCard card, bool isCurrentCard){
    if (!isCurrentCard || !_isAnswerVisible){
      return [];
    }
    Widget hintWidget = card.hint != null
        ? Text(
      card.hint,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20),
    )
        : Container();
    return [
      hintWidget,
      Text(
        card.answers[0].text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    ];
  }

  Widget _renderTinderCard(DeckCard card, int index){
    bool isCurrentCard = index == _nbRemainingCards - 1;

    return Positioned.fill(
      left: index * 5.0,
      top: index * 2.0,
      //TODO use Draggable
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: (isCorrect ? 1 : -1) * 0.02).animate(_animationController),
        child: GestureDetector(
          onTap: (){
            setState(() {
              _isAnswerVisible = true;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Card(
              elevation: 8,
              child: Container(
                color: Colors.orangeAccent,
                child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          card.question,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 30),
                        ),
                        ..._renderTinderCardSolutionPart(card, isCurrentCard)
                      ],
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderTinderLikeWidget(List<DeckCard> cards) {
    Size size = MediaQuery.of(context).size;
    List<Widget> cardWidgets = [];
    int index = 0;
    for (DeckCard c in cards){
      cardWidgets.add(_renderTinderCard(c, index));
      index++;
    }

    return Container(
      width: size.width,
      height: size.height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: _currentProgressValue,
          ),
          
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, left: 20, right: 20, bottom: 8),
              child: Stack(
                fit: StackFit.expand,
                children: cardWidgets,
              ),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: (){
                    isCorrect = false;
                    _animationController.forward();
                    _getToNextWord(false);

                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blueGrey, shape: BoxShape.circle),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.close, size: 50, color: Colors.white,),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    isCorrect = true;
                    _animationController.forward();
                    _getToNextWord(true);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(COLOR_ORANGE), shape: BoxShape.circle),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(Icons.check, size: 50, color: Colors.white,),
                    ),
                  ),
                ),

              ],
            ),
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              LocalizationWidget.of(context).getLocalizeValue('theme_words')),
        ),
        body: FutureBuilder(
          future: _cards,
          builder: (BuildContext context,
              AsyncSnapshot<List<DeckCard>> cardSnapshot) {
            switch (cardSnapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: Text(LocalizationWidget.of(context)
                      .getLocalizeValue('loading')),
                );
              case ConnectionState.done:
                return _renderTinderLikeWidget(_fetchedCards);
              default:
                return Center(
                  child: Text(LocalizationWidget.of(context)
                      .getLocalizeValue('generic_error')),
                );
            }
          },
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }
}
