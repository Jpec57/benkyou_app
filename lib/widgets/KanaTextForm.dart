import 'package:benkyou/services/translator/TextConversion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KanaController extends TextEditingController {}

class KanaEditableText extends EditableText {
  final bool isKana;
  final bool isReadOnly;
  final TextInputAction textInputAction;
  final TextAlign textAlign;

  KanaEditableText({
    Key key,
    int maxLines = 1,
    FocusNode focusNode,
    TextEditingController controller,
    TextStyle style,
    this.textAlign = TextAlign.start,
    bool autofocus = false,
    ValueChanged<String> onSubmitted,
    Color cursorColor,
    Color selectionColor,
    TextSelectionControls selectionControls,
    SelectionChangedCallback onSelectionChanged,
    this.textInputAction,
    this.isKana = true,
    this.isReadOnly = false,
  }) : super(
            key: key,
            focusNode: focusNode,
            controller: controller,
            cursorColor: cursorColor,
            backgroundCursorColor: Colors.black,
            style: style,
            keyboardType: TextInputType.text,
            autocorrect: false,
            autofocus: autofocus,
            maxLines: maxLines,
            textAlign: textAlign,
            textInputAction: textInputAction,
            selectionColor: selectionColor,
            selectionControls: selectionControls,
            onChanged: (text) async {
              if (text.isNotEmpty &&
                  isKana &&
                  !doesStringContainsKanji(text)) {
                String japanese = getDynamicHiraganaConversion(text);
                final origPosition = controller.selection.start;
                final origLength = text.length;
                final newLength = japanese.length;
                final newPosition = newLength - (origLength - origPosition);

                controller.value = controller.value.copyWith(
                    text: japanese,
                    composing: TextRange(start: 0, end: newPosition),
                    selection: TextSelection(
                        baseOffset: newPosition, extentOffset: newPosition));
              }
            },
            onSubmitted: onSubmitted,
            onSelectionChanged: onSelectionChanged,
            readOnly: isReadOnly);

  @override
  _KanaTextFormState createState() => new _KanaTextFormState();
}

class _KanaTextFormState extends EditableTextState {
  @override
  KanaEditableText get widget => super.widget;
}

class KanaTextForm extends StatelessWidget {
  final TextEditingController controller;
  final TextStyle style;
  final int maxLines;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final Color cursorColor;
  final Color selectionColor;
  final TextSelectionControls selectionControls;
  final bool isKana;
  final bool autofocus;
  final SelectionChangedCallback onSelectionChanged;
  final Color boxDecorationColor;
  final ValueChanged<String> onFieldSubmitted;
  final TextAlign textAlign;
  final TextInputAction textInputAction;
  final BoxDecoration boxDecoration;
  final bool isReadOnly;

  KanaTextForm(
      {Key key,
      this.maxLines = 1,
      @required this.focusNode,
      @required this.controller,
      this.style = const TextStyle(color: Colors.black),
      this.boxDecorationColor = Colors.white,
      this.onSubmitted,
      this.cursorColor = Colors.black,
      this.selectionColor,
      this.selectionControls,
      this.onSelectionChanged,
      this.isKana = true,
      this.autofocus = false,
      this.onFieldSubmitted,
      this.textAlign = TextAlign.start,
      this.textInputAction = TextInputAction.go,
      this.boxDecoration,
      this.isReadOnly = false});

  @override
  Widget build(BuildContext context) {
    BoxDecoration defaultBoxDecoration = BoxDecoration(
        color: boxDecorationColor,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12));

    return Container(
      decoration: boxDecoration ?? defaultBoxDecoration,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 8.0, right: 8.0, top: 12, bottom: 12),
        child: Center(
          child: KanaEditableText(
              cursorColor: cursorColor,
              focusNode: focusNode,
              style: style,
              isKana: isKana,
              textAlign: textAlign,
              onSubmitted: onSubmitted,
              autofocus: autofocus,
              controller: controller,
              isReadOnly: isReadOnly,
              maxLines: maxLines),
        ),
      ),
    );
  }
}
