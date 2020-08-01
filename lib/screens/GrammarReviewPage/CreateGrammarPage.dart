import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/InfoIcon.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:benkyou/widgets/SentenceSeekerWidget.dart';
import 'package:flutter/material.dart';

class CreateGrammarCardPage extends StatefulWidget {
  static const routeName = '/create/grammar';

  @override
  _CreateGrammarCardPageState createState() => _CreateGrammarCardPageState();
}

class _CreateGrammarCardPageState extends State<CreateGrammarCardPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _grammarPointName;
  TextEditingController _grammarPointMeaning;
  TextEditingController _grammarHint;
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _grammarPointName = new TextEditingController();
    _grammarPointMeaning = new TextEditingController();
    _grammarHint = new TextEditingController();
    _controllers.add(new TextEditingController());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _addSentence() {
    _controllers.add(new TextEditingController());
    setState(() {});
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
          Text(
            "Sentences including vocab",
            style: Theme.of(context).textTheme.headline6,
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
                            child: TextFormField(
                              controller: _controllers[index],
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                                borderSide: new BorderSide(),
                              )),
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
                    _renderField("Meaning/Translation", _grammarPointMeaning),
                    _renderField("Hint", _grammarHint,
                        info:
                            "While reviewing, if you were to ask for help, this hint will show up."),
                    _renderSentenceBuilderWidget(),
                    SentenceSeekerWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
