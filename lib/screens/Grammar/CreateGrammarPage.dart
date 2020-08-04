import 'package:benkyou/services/translator/TextConversion.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/ColorizedTextForm.dart';
import 'package:benkyou/widgets/InfoIcon.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:benkyou/widgets/SentenceSeekerWidget.dart';
import 'package:flutter/material.dart';

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
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _grammarPointName = new TextEditingController(text: "には");
    _grammarPointMeaning = new TextEditingController();
    _grammarHint = new TextEditingController();
    _controllers.add(new TextEditingController());
    _focusNodes.add(new FocusNode());
  }

  @override
  void dispose() {
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
    setState(() {});
  }

  Future<bool> isFormValid() async {
    String grammarPoint = _grammarPointName.text;
    String grammarMeaning = _grammarPointName.text;
    String grammarHint = _grammarPointName.text;
    List<String> gapSentences = [];
    if (grammarPoint.isEmpty) {
      return false;
    }
    if (grammarMeaning.isEmpty) {
      return false;
    }
    for (TextEditingController controller in _controllers) {
      String text = controller.text;
      if (text.isNotEmpty) {
        if (!text.contains("{$grammarPoint}")) {
          // A sentence does contain gap with grammar point
          return false;
        } else {
          gapSentences.add(text);
        }
      }
    }
    if (gapSentences.isEmpty) {
      return false;
    }
    print("All valid BG");
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
    //await postGrammarCard(deckId, map);

    return true;
  }

  Widget _renderField(String label, TextEditingController controller,
      {String info}) {
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
    int length = _controllers.length;
    print("text $text");
    print("length $length");
    TextEditingController lastController = _controllers[length - 1];
    // Use "{...}"
    String searchWord = _grammarPointName.text;
    text = text.replaceAll(searchWord, "{$searchWord}");
    if (lastController.text.isEmpty) {
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
      ),
      drawer: MainDrawer(),
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
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 15, right: 15, bottom: 50),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _renderField("Grammar point name", _grammarPointName),
                          _renderField(
                              "Meaning/Translation", _grammarPointMeaning),
                          _renderField("Hint", _grammarHint,
                              info:
                                  "While reviewing, if you were to ask for help, this hint will show up."),
                          _renderSentenceBuilderWidget(),
                          SentenceSeekerWidget(
                            searchTerm:
                                getJapaneseTranslation(_grammarPointName.text),
//                            searchTerm: _grammarPointName.text,
                            sentenceCallBack: sentenceCallback,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
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
