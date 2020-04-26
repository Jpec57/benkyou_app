import 'package:benkyou/models/DeckCard.dart';
import 'package:benkyou/models/JishoTranslation.dart';
import 'package:benkyou/screens/DeckPage/DeckPage.dart';
import 'package:benkyou/screens/DeckPage/DeckPageArguments.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/services/translator/TextConversion.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/AddAnswerCardWidget.dart';
import 'package:benkyou/widgets/JishoList.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const ERR_KANA = 'There is no kana in your question.';
const ERR_ANSWER = 'You must provide at least one answer.';
const ERR_KANA_KANJI = 'You must at least provide a kana or a kanji.';
const ERR_ALREADY_EXISTING =
    'A card has already the same kanji/kana.\n Please enter something else.';

class CreateCardPage extends StatefulWidget {
  static const routeName = '/cards/new';
  final int deckId;

  const CreateCardPage({Key key, this.deckId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CreateCardPageState();
}

class CreateCardPageState extends State<CreateCardPage> {
  final _formKey = GlobalKey<FormState>();
  String _bottomButtonLabel = 'NEXT';
  String japanese = '';
  String _error = '';
  String _researchWord = '';
  PageController _pageController =
      PageController(initialPage: 0, keepPage: false);

  TextEditingController _kanjiEditingController;
  TextEditingController _kanaEditingController;
  final FocusNode _kanjiFocusNode = FocusNode();
  final FocusNode _kanaFocusNode = FocusNode();
  bool _isQuestionErrorVisible = false;
  bool _isReversible = true;
  GlobalKey<AddAnswerCardWidgetState> answerWidgetKey =
      new GlobalKey<AddAnswerCardWidgetState>();

  void triggerJishoResearch(String text) async {
    setState(() {
      _researchWord = text;
    });
  }

  @override
  void initState() {
    super.initState();
    _kanjiEditingController = new TextEditingController();
    _kanaEditingController = new TextEditingController();

    _kanjiFocusNode.addListener(() {
      triggerJishoResearch(_kanjiEditingController.text);
    });

    _kanaFocusNode.addListener(() {
      triggerJishoResearch(_kanaEditingController.text);
    });
  }

  @override
  void dispose() {
    _kanjiEditingController.dispose();
    _kanaEditingController.dispose();
    _kanjiFocusNode.dispose();
    _kanaFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _createCardOrLeave() async {
    if (_pageController.page == 0) {
      String error = await _validateCreateCard();
      if (error != null) {
        //TODO prevent on error to refetch API
        setState(() {
          _isQuestionErrorVisible = true;
          _error = error;
        });
        _formKey.currentState.validate();
        return false;
      }

      //Format card
      String hint;
      String question;
      if (_kanaEditingController.text.trim().isNotEmpty) {
        hint = stringNeedToBeParsed(_kanaEditingController.text)
            ? getJapaneseTranslation(_kanaEditingController.text)
            : _kanaEditingController.text;
      }
      if (_kanjiEditingController.text.trim().isEmpty) {
        question = hint;
        hint = '';
      } else {
        question = _kanjiEditingController.text;
      }
      List<Map> answers = [];
      List<String> answerStrings =
          answerWidgetKey.currentState.getAnswerStrings();
      for (String string in answerStrings) {
        Map innerMap = new Map();
        innerMap.putIfAbsent('text', () => string);
        answers.add(innerMap);
      }
      //End formatting

      Map map = new Map();
      map.putIfAbsent('question', () => question);
      map.putIfAbsent('hint', () => hint);
      map.putIfAbsent('deck', () => widget.deckId);
      if (_isReversible) {
        map.putIfAbsent('isReversible', () => true);
      }
      map.putIfAbsent('answers', () => answers);
      postCard(widget.deckId, map);

      setState(() {
        _bottomButtonLabel = 'DONE';
      });
      //Hide keyboard
      FocusScope.of(context).requestFocus(FocusNode());
      _pageController.animateToPage(1,
          duration: Duration(milliseconds: 500), curve: Curves.easeIn);
    } else {
      Navigator.pushNamed(context, DeckPage.routeName,
          arguments: DeckPageArguments(widget.deckId));
    }
    return true;
  }

  Future<String> _validateCreateCard() async {
    String hint = _kanaEditingController.text.trim();
    String question = stringNeedToBeParsed(_kanaEditingController.text)
        ? getJapaneseTranslation(_kanjiEditingController.text)
        : _kanjiEditingController.text;
    if (question == null || question.trim().isEmpty) {
      //If no kanji is given, kana can be considered as question
      if (hint == null || hint.isEmpty) {
        return ERR_KANA_KANJI;
      }
      if (stringNeedToBeParsed(hint)) {
        hint = japanese;
      } else {}
      if (hint.isEmpty) {
        return ERR_KANA;
      }
      question = hint;
    }
    //At least one answer must not be blank
    List<String> answers = [];
    for (var answerController
        in answerWidgetKey.currentState.textEditingControllers) {
      if (answerController.text.isNotEmpty) {
        answers.add(answerController.text.toLowerCase());
      }
    }

    if (answers.isEmpty) {
      return ERR_ANSWER;
    }

    //Check if card already exists
    List<DeckCard> questionCards =
        await getCardsByQuestionInDeck(widget.deckId, question);
    if (questionCards.isNotEmpty) {
      return ERR_ALREADY_EXISTING;
    }
    return null;
  }

  //TODO WORK ABOVE

  void insertTranslationsCallback(JishoTranslation translation) {
    setState(() {
      _kanjiEditingController.text = translation.kanji;
      _kanaEditingController.text = translation.reading;
      _isQuestionErrorVisible = false;
      _error = null;
    });
    answerWidgetKey.currentState.setNewAnswers(translation.english);
  }

  bool stringNeedToBeParsed(String text) {
    int startLower = "a".codeUnitAt(0);
    int endLower = "z".codeUnitAt(0);
    int startUpper = "A".codeUnitAt(0);
    int endUpper = "Z".codeUnitAt(0);
    for (var i = 0; i < text.length; i++) {
      int char = text.codeUnitAt(i);
      if ((startLower <= char && char <= endLower) ||
          (startUpper <= char && char <= endUpper)) {
        return true;
      }
    }
    return false;
  }

  Widget _renderForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 50.0, right: 50.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: TextFormField(
                            controller: _kanaEditingController,
                            focusNode: _kanaFocusNode,
                            validator: (value) {
                              if (_isQuestionErrorVisible) {
                                return _error;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _isQuestionErrorVisible = false;
                              bool needtoBeParsed = stringNeedToBeParsed(
                                  _kanaEditingController.text);
                              setState(() {
                                japanese = needtoBeParsed
                                    ? "${getJapaneseTranslation(_kanaEditingController.text) ?? ''}"
                                    : '';
                              });
                              _formKey.currentState.validate();
                            },
                            textInputAction: TextInputAction.next,
                            autofocus: true,
                            decoration: InputDecoration(
                                labelText: 'Kana/Romaji to transform',
                                labelStyle: TextStyle(fontSize: 20),
                                hintText: 'Enter kana or romaji here'),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Column(children: <Widget>[
                            Text(japanese),
                            TextFormField(
                              focusNode: _kanjiFocusNode,
                              controller: _kanjiEditingController,
                              onChanged: (text) {
                                _isQuestionErrorVisible = false;
                                _formKey.currentState.validate();
                              },
                              validator: (value) {
                                if (_isQuestionErrorVisible) {
                                  if (_error != ERR_KANA) {
                                    return _error;
                                  }
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  labelText: 'Kanji',
                                  labelStyle: TextStyle(fontSize: 20),
                                  hintText: 'Enter kanji here'),
                            ),
                          ]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Is card reversible ?',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      'Another card inverting japanese and english will be created',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isReversible,
                              onChanged: (bool value) {
                                setState(() {
                                  _isReversible = !_isReversible;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: AddAnswerCardWidget(key: answerWidgetKey),
                      ),
                      Container(
                        child: Text(
                          'Propositions of answer',
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: JishoList(
                            researchWord: _researchWord,
                            callback: insertTranslationsCallback),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _resetFormFields() {
    _kanjiEditingController.clear();
    _kanaEditingController.clear();
    setState(() {
      japanese = '';
      _researchWord = '';
      _bottomButtonLabel = 'NEXT';
    });
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  Widget _renderAgainOrLeave() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Container(
            child: Center(
              child: Text(
                'Your card have been successfully created !',
                style: TextStyle(
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            _resetFormFields();
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.08,
            decoration: BoxDecoration(color: Color(COLOR_DARK_BLUE)),
            child: Center(
              child: Text(
                'CREATE ANOTHER CARD',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text("Create a card"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: _pageController,
              pageSnapping: false,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[_renderForm(), _renderAgainOrLeave()],
            ),
          ),
          GestureDetector(
              onTap: () async {
                _createCardOrLeave();
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(color: Color(COLOR_ORANGE)),
                child: Center(
                  child: Text(
                    _bottomButtonLabel,
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
