import 'package:benkyou/models/Deck.dart';
import 'package:benkyou/models/DeckCard.dart';
import 'package:benkyou/models/JishoTranslation.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/screens/DeckPage/DeckPage.dart';
import 'package:benkyou/screens/DeckPage/DeckPageArguments.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/services/api/deckRequests.dart';
import 'package:benkyou/services/localStorage/localStorageService.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/AddAnswerCardWidget.dart';
import 'package:benkyou/widgets/JishoList.dart';
import 'package:benkyou/widgets/KanaTextForm.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/TextRecognizerIcon.dart';
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
  Future<Deck> _deck;
  final _formKey = GlobalKey<FormState>();
  String _bottomButtonLabel = '';
  String _error = '';
  String _researchWord = '';
  PageController _pageController =
      PageController(initialPage: 0, keepPage: false);

  TextEditingController _kanjiEditingController;
  TextEditingController _kanaEditingController;
  final FocusNode _kanjiFocusNode = FocusNode();
  final FocusNode _kanaFocusNode = FocusNode();
  bool _isQuestionErrorVisible = false;
  GlobalKey<AddAnswerCardWidgetState> answerWidgetKey;

  void triggerJishoResearch(String text) async {
    setState(() {
      _researchWord = text;
    });
  }

  @override
  void initState() {
    super.initState();
    answerWidgetKey = new GlobalKey<AddAnswerCardWidgetState>();
    _kanjiEditingController = new TextEditingController();
    _kanaEditingController = new TextEditingController();
    _deck = getDeck(widget.deckId);

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
        hint = _kanaEditingController.text.trim();
      }
      if (_kanjiEditingController.text.trim().isEmpty) {
        question = hint;
        hint = '';
      } else {
        question = _kanjiEditingController.text.trim();
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
      map.putIfAbsent('isReversible', () => true);
      map.putIfAbsent('answers', () => answers);
      postCard(widget.deckId, map);
      setLastUsedDeckIdFromLocalStorage(widget.deckId);

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
    String question = _kanjiEditingController.text.trim().isEmpty
        ? _kanaEditingController.text.trim()
        : _kanjiEditingController.text.trim();
    if (question == null || question.trim().isEmpty) {
      //If no kanji is given, kana can be considered as question
      if (hint == null || hint.isEmpty) {
        return ERR_KANA_KANJI;
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

  void insertTranslationsCallback(JishoTranslation translation) {
    setState(() {
      _kanjiEditingController.text = translation.kanji;
      _kanaEditingController.text = translation.reading;
      _isQuestionErrorVisible = false;
      _error = null;
    });
    answerWidgetKey.currentState.setNewAnswers(translation.english);
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 50.0, right: 50.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8.0, top: 10),
                              child: Text(
                                LocalizationWidget.of(context)
                                    .getLocalizeValue('word_to_translate'),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                  flex: 4,
                                  child: KanaTextForm(
                                    controller: _kanaEditingController,
                                    autofocus: true,
                                    textInputAction: TextInputAction.next,
                                    focusNode: _kanaFocusNode,
                                  )),
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Center(
                                    child: ClipOval(
                                      child: Container(
                                        color: Color(COLOR_ORANGE),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextRecognizerIcon(
                                            color: Colors.white,
                                            size: 20,
                                            callback: (kanji) {
                                              setState(() {
                                                _kanaEditingController.text =
                                                    kanji;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Container(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10.0),
                              child: Column(children: <Widget>[
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
                                      labelText: LocalizationWidget.of(context)
                                          .getLocalizeValue('kanji'),
                                      labelStyle: TextStyle(fontSize: 20),
                                      hintText: LocalizationWidget.of(context)
                                          .getLocalizeValue(
                                              'input_kanji_label')),
                                ),
                              ]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 50.0),
                            child: AddAnswerCardWidget(key: answerWidgetKey),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                child: Text(
                                  LocalizationWidget.of(context)
                                      .getLocalizeValue('prop_of_answer'),
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  LocalizationWidget.of(context)
                                      .getLocalizeValue('powered_by_jisho'),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 10, right: 10, bottom: 30.0),
                                child: JishoList(
                                    researchWord: _researchWord,
                                    callback: insertTranslationsCallback),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
      _researchWord = '';
      _bottomButtonLabel =
          LocalizationWidget.of(context).getLocalizeValue('next').toUpperCase();
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
                LocalizationWidget.of(context)
                    .getLocalizeValue('create_card_success'),
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
                LocalizationWidget.of(context)
                    .getLocalizeValue('create_another_card')
                    .toUpperCase(),
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _renderHeader() {
    Widget defaultHeader =
        Text(LocalizationWidget.of(context).getLocalizeValue('create_card'));
    return FutureBuilder(
      future: _deck,
      builder: (BuildContext context, AsyncSnapshot<Deck> deckSnap) {
        switch (deckSnap.connectionState) {
          case ConnectionState.done:
            if (deckSnap.hasData) {
              return Text(LocalizationWidget.of(context)
                      .getLocalizeValue('create_card') +
                  " in ${deckSnap.data.title}");
            }
            return defaultHeader;
          default:
            return defaultHeader;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _bottomButtonLabel =
        LocalizationWidget.of(context).getLocalizeValue('next').toUpperCase();

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed(DeckHomePage.routeName);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: _renderHeader(),
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
      ),
    );
  }
}
