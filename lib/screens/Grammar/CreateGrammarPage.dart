import 'package:benkyou/models/GrammarPointCard.dart';
import 'package:benkyou/screens/Grammar/GrammarCardListPage.dart';
import 'package:benkyou/screens/Grammar/GrammarHomePage.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/services/translator/TextConversion.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/ColorizedTextForm.dart';
import 'package:benkyou/widgets/InfoIcon.dart';
import 'package:benkyou/widgets/KanaTextForm.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/SentenceSeekerWidget.dart';
import 'package:benkyou/widgets/TextRecognizerIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';

class CreateGrammarCardPage extends StatefulWidget {
  static const routeName = '/create/grammar';
  final int deckId;
  final int grammarCardId;

  const CreateGrammarCardPage(
      {Key key, @required this.deckId, this.grammarCardId})
      : super(key: key);

  @override
  _CreateGrammarCardPageState createState() => _CreateGrammarCardPageState();
}

class _CreateGrammarCardPageState extends State<CreateGrammarCardPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _grammarPointName;
  TextEditingController _grammarPointMeaning;
  TextEditingController _grammarHint;
  Future<GrammarPointCard> _grammarCardEditedFuture;
  GrammarPointCard _grammarCardEdited;
  String _researchTerm;
  List<TextEditingController> _controllers = [];
  List<TextEditingController> _synonymControllers = [];
  FocusNode _grammarNameFocus;
  List<FocusNode> _focusNodes = [];
  List<FocusNode> _synonymFocusNodes = [];
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _grammarPointName = new TextEditingController();
    _grammarNameFocus = new FocusNode();
    _grammarNameFocus.addListener(() {
      if (!_grammarNameFocus.hasFocus && _grammarPointName.text != null) {
        setState(() {
          _researchTerm = getJapaneseTranslation(_grammarPointName.text);
        });
      }
    });
    _grammarPointMeaning = new TextEditingController();
    _grammarHint = new TextEditingController();
    _controllers.add(new TextEditingController());
    _focusNodes.add(new FocusNode());
    getEditedGrammarCard();
  }

  void getEditedGrammarCard() async {
    _grammarCardEditedFuture = getUserGrammarCard(widget.grammarCardId);
    if (widget.grammarCardId != null) {
      _grammarCardEdited = await getUserGrammarCard(widget.grammarCardId);
      _grammarPointName.text = _grammarCardEdited.question;
      var answers = _grammarCardEdited.answers;
      if (answers != null && answers.length > 0) {
        _grammarPointMeaning.text = answers[0].text;
      }
      _grammarHint.text = _grammarCardEdited.hint;
      List<String> synonyms = _grammarCardEdited.acceptedAnswers;
      int i = 0;
      for (String syn in synonyms) {
        if (_synonymControllers.length > i) {
          _synonymControllers[i].text = syn;
        } else {
          _synonymControllers.add(new TextEditingController());
          _synonymFocusNodes.add(new FocusNode());
          _synonymControllers[i].text = syn;
        }
        i++;
      }
      i = 0;
      List<String> gapSentences = _grammarCardEdited.gapSentences;
      for (String sent in gapSentences) {
        if (_controllers.length > i) {
          _controllers[i].text = sent;
        } else {
          _controllers.add(new TextEditingController());
          _focusNodes.add(new FocusNode());
          _controllers[i].text = sent;
        }
        i++;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _grammarPointName.dispose();
    _grammarHint.dispose();
    _grammarPointMeaning.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _synonymControllers) {
      controller.dispose();
    }
    for (var node in _synonymFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _addSynonym() {
    _synonymFocusNodes.add(new FocusNode());
    _synonymControllers.add(new TextEditingController());
    _synonymFocusNodes[_synonymFocusNodes.length - 1].requestFocus();
    setState(() {});
  }

  void _addSentence() {
    _focusNodes.add(new FocusNode());
    _controllers.add(new TextEditingController());
    _focusNodes[_focusNodes.length - 1].requestFocus();
    setState(() {});
  }

  Future<bool> isFormValid() async {
    String grammarPoint = _grammarPointName.text;
    String grammarMeaning = _grammarPointMeaning.text;
    String grammarHint = _grammarHint.text;
    List<String> gapSentences = [];
    if (grammarPoint.isEmpty) {
      Get.snackbar("Error", "The name of your grammar point cannot be empty.",
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (grammarMeaning.isEmpty) {
      Get.snackbar("Error",
          "The meaning/translation of your grammar point cannot be empty.",
          snackPosition: SnackPosition.TOP);
      return false;
    }
    for (TextEditingController controller in _controllers) {
      String text = controller.text;
      if (text.isNotEmpty) {
        RegExp regExp = new RegExp(r"{[^}]+}");
        if (regExp.hasMatch(text)) {
          gapSentences.add(text);
        }
      }
    }
    List<String> acceptedAnswers = [];
    for (TextEditingController controller in _synonymControllers) {
      String text = controller.text;
      if (text.isNotEmpty) {
        acceptedAnswers.add(text);
      }
    }
    if (gapSentences.isEmpty) {
      Get.snackbar(
          "Error", "You must provide at least one correct gap sentence.",
          snackPosition: SnackPosition.TOP);

      return false;
    }
    List<Map> answers = [];
    Map innerMap = new Map();
    innerMap.putIfAbsent('text', () => grammarMeaning);
    answers.add(innerMap);

    Map map = new Map();
    //TODO
    if (_grammarCardEdited != null && _grammarCardEdited.id != null) {
      map.putIfAbsent('id', () => _grammarCardEdited.id);
    }
    map.putIfAbsent('question', () => grammarPoint);
    map.putIfAbsent('hint', () => grammarHint);
    map.putIfAbsent('gapSentences', () => gapSentences);
    map.putIfAbsent('deck', () => widget.deckId);
    map.putIfAbsent('answers', () => answers);
    map.putIfAbsent('acceptedAnswers', () => acceptedAnswers);
    GrammarPointCard grammarPointCard =
        await postGrammarCard(widget.deckId, map);
    if (grammarPointCard != null) {
      clearAllFields();
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
      Get.snackbar(
          "Success",
          _grammarCardEdited != null
              ? "Your card has correctly been edited."
              : "Your card has correctly been created.",
          snackPosition: SnackPosition.TOP);
      if (_grammarCardEdited != null) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            GrammarCardListPage.routeName,
            ModalRoute.withName(GrammarCardListPage.routeName));
      }
    }

    return true;
  }

  void clearAllFields() {
    _grammarPointMeaning.clear();
    _grammarPointName.clear();
    _grammarHint.clear();
    int length = _controllers.length;
    if (length > 0) {
      _controllers[0].clear();
    }
    if (length > 1) {
      _controllers.removeRange(1, _controllers.length);
    }
    int synLength = _synonymControllers.length;
    if (synLength > 0) {
      _synonymControllers.removeRange(0, synLength);
    }
    setState(() {});
  }

  Widget _renderField(String label, TextEditingController controller,
      {String info, bool isMainField = false, bool isTextArea = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 8.0),
            child: Row(
              children: [
                Text(
                  label,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headline6,
                ),
                info != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: InfoIcon(
                          info: info,
                        ),
                      )
                    : Container()
              ],
            ),
          ),
          TextFormField(
            maxLength: 255,
            textCapitalization: isMainField
                ? TextCapitalization.none
                : TextCapitalization.sentences,
            controller: controller,
            maxLines: isTextArea ? null : 1,
            focusNode: isMainField ? _grammarNameFocus : null,
            decoration: InputDecoration(
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(15.0),
                  borderSide: new BorderSide(),
                )),
          ),
        ],
      ),
    );
  }

  Widget _renderSynonymBuilderWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                LocalizationWidget.of(context).getLocalizeValue('synonyms'),
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontStyle: FontStyle.italic),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: InfoIcon(
                  info: LocalizationWidget.of(context)
                      .getLocalizeValue('synonym_info'),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 15),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: _synonymControllers.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction) {
                      _synonymControllers.removeAt(index);
                      _synonymFocusNodes.removeAt(index);
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Container(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, bottom: 8.0, left: 8, right: 20),
                              child: Text(
                                "${index + 1}",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(12)),
                                child: TextFormField(
                                    decoration: InputDecoration(
                                        border: InputBorder.none),
                                    style: TextStyle(color: Colors.black),
                                    focusNode: _synonymFocusNodes[index],
                                    controller: _synonymControllers[index],
                                    maxLines: 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
          GestureDetector(
            onTap: () {
              _addSynonym();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Color(COLOR_ANTRACITA),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _renderSentenceBuilderWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              LocalizationWidget.of(context).getLocalizeValue('gap_sentences'),
              style: Theme.of(context).textTheme.headline6,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: InfoIcon(
                info: LocalizationWidget.of(context)
                    .getLocalizeValue('gap_sentence_info'),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipOval(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      color: Color(COLOR_MUSTARD),
                      child: TextRecognizerIcon(
                        size: 20,
                        color: Colors.black,
                        callback: sentenceCallback,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    _controllers.removeAt(index);
                    _focusNodes.removeAt(index);
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, bottom: 8.0, left: 8, right: 20),
                            child: Text(
                              "${index + 1}",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0, top: 12, bottom: 12),
                                child: ColorizedTextForm(
                                    cursorColor: Colors.black,
                                    style: TextStyle(color: Colors.black),
                                    focusNode: _focusNodes[index],
                                    controller: _controllers[index],
                                    regexAnnotation: RegexAnnotation(
                                        style: TextStyle(color: Colors.red),
                                        regex: new RegExp(r"{[^}]+}")),
                                    maxLines: null),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
        GestureDetector(
          onTap: () {
            _addSentence();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Color(COLOR_ORANGE),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  String sentenceCallback(String text) {
    TextEditingController lastController;
    for (var controller in _controllers) {
      if (controller.text.isEmpty) {
        lastController = controller;
        break;
      }
    }
    // Use "{...}"
    String searchWord = _grammarPointName.text;
    if (searchWord.isNotEmpty) {
      text = text.replaceAll(searchWord, "{$searchWord}");
    }
    if (lastController != null) {
      lastController.text = text;
    } else {
      _focusNodes.add(new FocusNode());
      _controllers.add(new TextEditingController(text: text));
    }
    setState(() {});
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: _grammarCardEditedFuture,
          builder:
              (BuildContext context, AsyncSnapshot<GrammarPointCard> gramSnap) {
            var defaultWidget = Text('Create Grammar point');
            switch (gramSnap.connectionState) {
              case ConnectionState.done:
                if (!gramSnap.hasData) {
                  return defaultWidget;
                }
                return Text('Edit Grammar point with id ${gramSnap.data.id}');
              default:
                return defaultWidget;
            }
          },
        ),
        leading: IconButton(
          onPressed: () {
            if (widget.grammarCardId != null) {
              Navigator.pushNamed(context, GrammarCardListPage.routeName);
            } else {
              Navigator.pushNamed(context, GrammarHomePage.routeName);
            }
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 15, right: 15, bottom: 50),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Grammar point name",
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    ],
                                  ),
                                ),
                                KanaTextForm(
                                  boxDecoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  controller: _grammarPointName,
                                  focusNode: _grammarNameFocus,
                                  isReadOnly: false,
                                  autofocus: true,
                                ),
                              ],
                            ),
                          ),
                          _renderField(
                              "Meaning/Translation", _grammarPointMeaning,
                              isTextArea: true),
                          _renderField("Hint", _grammarHint,
                              isTextArea: true,
                              info:
                                  "While reviewing, if you were to ask for help, this hint will show up. If it is empty, the meaning will be displayed as hint."),
                          _renderSynonymBuilderWidget(),
                          _renderSentenceBuilderWidget(),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: SentenceSeekerWidget(
                              searchTerm: _researchTerm,
                              sentenceCallBack: sentenceCallback,
                            ),
                          ),
                          FutureBuilder(
                            future: _grammarCardEditedFuture,
                            builder: (BuildContext context,
                                AsyncSnapshot<GrammarPointCard> grammarSnap) {
                              switch (grammarSnap.connectionState) {
                                case ConnectionState.done:
                                  if (!grammarSnap.hasData) {
                                    return Container();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: GestureDetector(
                                      onTap: () {
                                        deleteCard(grammarSnap.data.id);
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                GrammarCardListPage.routeName,
                                                ModalRoute.withName(
                                                    GrammarCardListPage
                                                        .routeName));
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: Color(COLOR_DARK_RED),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15, bottom: 15),
                                          child: Text(
                                            "Delete card".toUpperCase(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                default:
                                  return Container();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  isFormValid();
                },
                child: Container(
                  width: double.infinity,
                  color: Color(COLOR_MUSTARD),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Text(
                      (_grammarCardEdited != null ? "Edit" : "Create")
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
