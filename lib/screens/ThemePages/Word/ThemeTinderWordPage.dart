import 'dart:math';

import 'package:benkyou/models/DeckCard.dart';
import 'package:benkyou/models/DeckTheme.dart';
import 'package:benkyou/models/UserCard.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/screens/HomePage/HomePage.dart';
import 'package:benkyou/screens/ThemePages/Listening/ThemeListeningPartPageArguments.dart';
import 'package:benkyou/screens/ThemePages/ThemeLearningHomePage.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/ConfirmDialog.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/ThemeTransitionDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';

import '../Listening/ThemeListeningPartPage.dart';

class ThemeTinderWordPage extends StatefulWidget {
  static const routeName = '/themes/words';
  final DeckTheme theme;

  const ThemeTinderWordPage({Key key, this.theme}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeTinderWordPageState();
}

class ThemeTinderWordPageState extends State<ThemeTinderWordPage>
    with TickerProviderStateMixin {
  Future<List<DeckCard>> _cards;
  List<DeckCard> _fetchedCards;
  int _currentIndex;
  int _nbRemainingCards = 0;
  int _nbSuccess = 0;
  int _nbErrors = 0;
  int _initNbCards = 0;
  double _currentProgressValue = 0;
  bool _isAnswerVisible = false;
  bool _isChoiceMade = false;
  Offset _startOffset;
  double _offset = 0;
  AnimationController _animationController;

  void initCards() async {
    _cards = getRandomThemeCardsInDeck(widget.theme.deck.id, 10);
    _fetchedCards = await _cards;
    _nbRemainingCards = _fetchedCards.length;
    _currentIndex = _nbRemainingCards - 1;
    _initNbCards = _nbRemainingCards;
  }

  @override
  void initState() {
    super.initState();
    initCards();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              ThemeTransitionDialog(name: 'Vocabulary'));
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    });
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _handleChoice(bool isAccepting) {
    if (isAccepting) {
      _animationController.forward();
      _getToNextWord(true);
    } else {
      _animationController.forward();
      _getToNextWord(false);
    }
  }

  void _getToNextWord(bool isSuccess) {
    if (isSuccess) {
      _nbSuccess++;
      _currentProgressValue = _nbSuccess / _initNbCards;
      if (_currentIndex - 1 >= 0) {
        _currentIndex--;
        _nbRemainingCards--;
        _fetchedCards.removeLast();
      } else {
        Navigator.of(context).pushNamed(ThemeListeningPartPage.routeName,
            arguments: ThemeListeningPartPageArguments(widget.theme));
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

  List<Widget> _renderTinderCardSolutionPart(
      DeckCard card, bool isCurrentCard) {
    if (!isCurrentCard || !_isAnswerVisible) {
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

  Widget _renderDefaultCard(DeckCard card, bool isCurrentCard) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Color(COLOR_DARK_MUSTARD),
            border: Border.all(color: Colors.black54),
            borderRadius: BorderRadius.circular(10),

        ),
        child: Stack(
          children: [
            Center(
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
          ],
        ),
      ),
    );
  }

  Widget _renderMainTinderCard(DeckCard card) {
    return Listener(
      onPointerMove: (PointerMoveEvent event) {
        _offset = event.position.dx - _startOffset.dx;
        if (_offset > 50 || _offset < -50) {
          _isChoiceMade = true;
        } else {
          _isChoiceMade = false;
        }
        setState(() {});
      },
      onPointerDown: (PointerDownEvent event) {
        _startOffset = event.position;
      },
      onPointerUp: (PointerUpEvent event) {
        if (_isChoiceMade) {}
      },
      child: Draggable(
        feedback: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: Color(COLOR_ORANGE),
            ),
          ),
        ),
        onDragEnd: (a) {
          if (_isChoiceMade) {
            _handleChoice(_offset > 0);
          }
        },
        childWhenDragging: Transform.rotate(
          angle: _offset != null ? _offset / 1000 : 0,
          child: Transform.translate(
            offset: Offset(_offset != null ? _offset * 2 : 0, 0),
            child: Stack(children: [
              _renderDefaultCard(card, true),
              Align(
                alignment: _offset > 0 ? Alignment.topLeft : Alignment.topRight,
                child: Visibility(
                    visible: _isChoiceMade,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      _offset > 0 ? Colors.green : Colors.red),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            _offset > 0 ? 'MEMORIZED' : 'AGAIN',
                            style: TextStyle(
                                color: _offset > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )),
                    )),
              )
            ]),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isAnswerVisible = true;
            });
          },
          child: _renderDefaultCard(card, true),
        ),
      ),
    );
  }

  Widget _renderTinderCard(DeckCard card, int index) {
    bool isCurrentCard = index == _nbRemainingCards - 1;
    return isCurrentCard
        ? _renderMainTinderCard(card)
        : _renderDefaultCard(card, false);
  }

  Widget _decisionRowWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              _handleChoice(false);
            },
            child: Container(
              decoration:
                  BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.close,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _handleChoice(true);
            },
            child: Container(
              decoration:
                  BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.check,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderTinderTarget(bool isMemorized) {
    return DragTarget(
      builder: (BuildContext context, List<dynamic> candidateData,
          List<dynamic> rejectedData) {
        return Container(
//          color: isMemorized ? Colors.green : Colors.red,
          width: MediaQuery.of(context).size.width * 0.1,
        );
      },
      onAccept: (value) {
        _handleChoice(isMemorized);
      },
    );
  }

  Widget _renderTinderLikeWidget(List<DeckCard> cards) {
    Size size = MediaQuery.of(context).size;
    List<Widget> cardWidgets = [];
    int index = 0;
    for (DeckCard c in cards) {
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
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: LinearProgressIndicator(
              value: _currentProgressValue,
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _renderTinderTarget(false),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: OverflowBox(
                    child: Stack(
                      overflow: Overflow.visible,
                      fit: StackFit.expand,
                      children: [
                        ...cardWidgets,
                      ],
                    ),
                  ),
                ),
                _renderTinderTarget(true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Align(
                alignment: Alignment.bottomCenter, child: _decisionRowWidget()),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.dialog(ConfirmDialog(
          action:
              LocalizationWidget.of(context).getLocalizeValue('quit_session'),
          positiveCallback: () async {
            Navigator.of(context).pushNamedAndRemoveUntil(
                ThemeLearningHomePage.routeName,
                ModalRoute.withName(ThemeLearningHomePage.routeName));
          },
          shouldAlwaysPop: false,
        ));
        return Future.value(false);
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(
                LocalizationWidget.of(context).getLocalizeValue('theme_vocab')),
          ),
          body: FutureBuilder(
            future: _cards,
            builder: (BuildContext context,
                AsyncSnapshot<List<DeckCard>> cardSnapshot) {
              switch (cardSnapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                case ConnectionState.done:
                  if (!cardSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return _renderTinderLikeWidget(_fetchedCards);
                default:
                  return Center(
                    child: Text(LocalizationWidget.of(context)
                        .getLocalizeValue('generic_error')),
                  );
              }
            },
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }
}
