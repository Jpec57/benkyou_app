import 'package:benkyou/models/GrammarPointCard.dart';
import 'package:benkyou/screens/Grammar/GrammarHomePage.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/services/translator/TextConversion.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/ColorizedTextForm.dart';
import 'package:benkyou/widgets/InfoIcon.dart';
import 'package:benkyou/widgets/SentenceSeekerWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateGrammarCardPage extends StatefulWidget {
  static const routeName = '/create/grammar';
  final int deckId;

  const CreateGrammarCardPage({Key key, @required this.deckId})
      : super(key: key);

  @override
  _CreateGrammarCardPageState createState() => _CreateGrammarCardPageState();
}

class _CreateGrammarCardPageState extends State<CreateGrammarCardPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _grammarPointName;
  TextEditingController _grammarPointMeaning;
  TextEditingController _grammarHint;
  String _researchTerm;
  List<TextEditingController> _controllers = [];
  FocusNode _grammarNameFocus;
  List<FocusNode> _focusNodes = [];
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
    super.dispose();
  }

  void _addSentence() {
    _focusNodes.add(new FocusNode());
    _controllers.add(new TextEditingController());
    _focusNodes[_focusNodes.length - 1].requestFocus();
    setState(() {});
  }

  Future<bool> isFormValid() async {
    String grammarPoint = getJapaneseTranslation(_grammarPointName.text);
    String grammarMeaning = _grammarPointName.text;
    String grammarHint = _grammarHint.text;
    List<String> gapSentences = [];
    if (grammarPoint.isEmpty) {
      Get.snackbar("Error", "The name of your grammar point cannot be empty.",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (grammarMeaning.isEmpty) {
      Get.snackbar("Error",
          "The meaning/translation of your grammar point cannot be empty.",
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    for (TextEditingController controller in _controllers) {
      String text = controller.text;
      print("IN $text");
      if (text.isNotEmpty) {
        RegExp regExp = new RegExp(r"{[^}]+}");
        if (regExp.hasMatch(text)) {
          gapSentences.add(text);
        } else {
          //          Get.snackbar("Error", "Your sentence must contain a gap",
//              snackPosition: SnackPosition.BOTTOM);

          // A sentence does contain gap with grammar point
//          return false;
        }
      }
    }
    if (gapSentences.isEmpty) {
      Get.snackbar(
          "Error", "You must provide at least one correct gap sentence.",
          snackPosition: SnackPosition.BOTTOM);

      return false;
    }
    List<Map> answers = [];
    Map innerMap = new Map();
    innerMap.putIfAbsent('text', () => grammarMeaning);
    answers.add(innerMap);

    Map map = new Map();
    map.putIfAbsent('question', () => grammarPoint);
    map.putIfAbsent('hint', () => grammarHint);
    map.putIfAbsent('gapSentences', () => gapSentences);
    map.putIfAbsent('deck', () => widget.deckId);
    map.putIfAbsent('answers', () => answers);
    GrammarPointCard grammarPointCard =
        await postGrammarCard(widget.deckId, map);
    if (grammarPointCard != null) {
      clearAllFields();
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
      Get.snackbar("Success", "Your card has correctly been created.",
          snackPosition: SnackPosition.BOTTOM);
    }

    return true;
  }

  void clearAllFields() {
    _grammarPointMeaning.clear();
    _grammarPointName.clear();
    _grammarHint.clear();
    _controllers[0].clear();
    _controllers.removeRange(1, _controllers.length);
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
            controller: controller,
            maxLines: isTextArea ? null : 1,
            focusNode: isMainField ? _grammarNameFocus : null,
            decoration: InputDecoration(
                border: OutlineInputBorder(
              borderRadius: new BorderRadius.circular(15.0),
              borderSide: new BorderSide(),
            )),
          ),
        ],
      ),
    );
  }

  Widget _renderSentenceBuilderWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                "Gap Sentences",
                style: Theme.of(context).textTheme.headline6,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: InfoIcon(
                  info:
                      "Surround with curly braces the part you want later to fill. Usually, it matches the grammar point name content.",
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
                  return Padding(
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
      ),
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
    String searchWord = getJapaneseTranslation(_grammarPointName.text);
    text = text.replaceAll(searchWord, "{$searchWord}");
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
        title: Text('Create Grammar point'),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, GrammarHomePage.routeName);
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
                          _renderField("Grammar point name", _grammarPointName,
                              isMainField: true),
                          _renderField(
                              "Meaning/Translation", _grammarPointMeaning,
                              isTextArea: true),
                          _renderField("Hint", _grammarHint,
                              isTextArea: true,
                              info:
                                  "While reviewing, if you were to ask for help, this hint will show up. If it is empty, the meaning will be displayed as hint."),
                          _renderSentenceBuilderWidget(),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: SentenceSeekerWidget(
                              searchTerm: _researchTerm,
                              sentenceCallBack: sentenceCallback,
                            ),
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
                      "Create".toUpperCase(),
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
