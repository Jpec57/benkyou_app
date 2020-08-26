import 'package:benkyou/widgets/KanaTextForm.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  static const routeName = '/test';

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  TextEditingController _kanaController;
  FocusNode _focusNode;
  bool isKana = true;

  @override
  void initState() {
    super.initState();
    _kanaController = new TextEditingController();
    _kanaController.addListener(() {
//      final text = _kanaController.text;
//      print(text);
//      String japanese = getDynamicHiraganaConversion(text);
//      final origPosition = _kanaController.selection.start;
//      final origLength = text.length;
//      final newLength = japanese.length;
//      final newPosition = newLength - (origLength - origPosition);
//
//      _kanaController.value = _kanaController.value.copyWith(
//          text: japanese,
//          selection: TextSelection(
//              baseOffset: newPosition, extentOffset: newPosition));
    });
    _focusNode = new FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _kanaController.dispose();
    _focusNode.dispose();
  }

  void changeKana() {
    setState(() {
      isKana = !isKana;
    });
    print(isKana);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TEST"),
      ),
      drawer: MainDrawer(),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: KanaTextForm(
                  cursorColor: Colors.black,
                  isKana: isKana,
                  focusNode: _focusNode,
                  controller: _kanaController,
                  maxLines: null),
            ),
            RaisedButton(
              onPressed: () {
                changeKana();
              },
              child: Text("Hello"),
            )
          ],
        ),
      ),
    );
  }
}
