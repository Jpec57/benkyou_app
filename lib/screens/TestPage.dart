import 'package:benkyou/services/translator/TextConversion.dart';
import 'package:benkyou/widgets/KanaTextForm.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:benkyou/widgets/TextRecognizerIcon.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  static const routeName = '/test';

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  TextEditingController _kanaController;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _kanaController = new TextEditingController(text: 'saikou');
    _kanaController.addListener(() {
      print('----------------');

      int japaneseOffset = getJapaneseOffsetFromString(_kanaController.text,
          HIRAGANA_ALPHABET, _kanaController.selection.extentOffset);
      print("res $japaneseOffset");
//      _kanaController.selection = TextSelection.fromPosition(
//        TextPosition(offset: japaneseOffset),
//      );
      print(
          "change ${_kanaController.text} offset ${_kanaController.selection.extentOffset}");
    });
    _focusNode = new FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _kanaController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Draw kanji"),
      ),
      drawer: MainDrawer(),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 12, bottom: 12),
                  child: KanaTextForm(
                      cursorColor: Colors.black,
                      focusNode: _focusNode,
                      onChanged: (text) async {
                        print(text);
                        return;
                      },
                      style: TextStyle(),
                      controller: _kanaController,
                      maxLines: null),
                ),
              ),
            ),
            Center(
              child: Text("Not implemented yet."),
            ),
            TextRecognizerIcon(
              callback: (str) {
                print("Callback $str");
              },
            ),
          ],
        ),
      ),
    );
  }
}
