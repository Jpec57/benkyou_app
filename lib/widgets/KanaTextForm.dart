import 'package:benkyou/services/translator/TextConversion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KanaController extends TextEditingController {}

class KanaTextForm extends EditableText {
  KanaTextForm({
    Key key,
    int maxLines = 1,
    FocusNode focusNode,
    TextEditingController controller,
    TextStyle style,
    ValueChanged<String> onChanged,
    ValueChanged<String> onSubmitted,
    Color cursorColor,
    Color selectionColor,
    TextSelectionControls selectionControls,
    SelectionChangedCallback onSelectionChanged,
    this.isKana,
  }) : super(
          key: key,
          focusNode: focusNode,
          controller: controller,
          cursorColor: cursorColor,
          backgroundCursorColor: Colors.black,
          style: style,
          keyboardType: TextInputType.text,
          autocorrect: false,
          autofocus: false,
          maxLines: maxLines,
          selectionColor: selectionColor,
          selectionControls: selectionControls,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onSelectionChanged: onSelectionChanged,
        );

  final bool isKana;

  @override
  _KanaTextFormState createState() => new _KanaTextFormState();
}

class _KanaTextFormState extends EditableTextState {
  @override
  KanaTextForm get widget => super.widget;

  @override
  TextSpan buildTextSpan() {
    final String text = textEditingValue.text;
    String japanese = getJapaneseTranslation(text);
    print("original $text");
    print("japanese $japanese");
    int textLength = text.length;
    int japaneseTextLength = japanese.length;
    return new TextSpan(style: widget.style, text: japanese);
  }
}
