import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'KanaTextForm.dart';

class CompleteTextDialog extends StatefulWidget {
  final Function positiveCallback;
  final String text;
  final isKana;

  const CompleteTextDialog(
      {Key key,
      this.text,
      @required this.positiveCallback,
      this.isKana = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => CompleteTextDialogState();
}

class CompleteTextDialogState extends State<CompleteTextDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController(text: widget.text);
    _focusNode = new FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.all(10.0),
      title: Text(
          LocalizationWidget.of(context).getLocalizeValue('add_edit_text')),
      content: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.height * 0.7,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: KanaTextForm(
                      cursorColor: Colors.black,
                      isKana: widget.isKana,
                      focusNode: _focusNode,
                      controller: _controller,
                      maxLines: null),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, top: 15.0),
                  child: IntrinsicHeight(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Color(COLOR_ORANGE),
                      child: Text(
                        LocalizationWidget.of(context)
                            .getLocalizeValue('save')
                            .toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        widget.positiveCallback(_controller.text);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
