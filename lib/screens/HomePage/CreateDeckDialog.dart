import 'package:benkyou_app/services/api/deckRequests.dart';
import 'package:flutter/material.dart';

class CreateDeckDialog extends StatefulWidget {
  final Function callback;

  const CreateDeckDialog({Key key, this.callback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CreateDeckDialogState();
}

class CreateDeckDialogState extends State<CreateDeckDialog> {
  TextEditingController _titleController;


  @override
  void initState() {
    super.initState();
    _titleController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.all(15.0),
      title: Text('Create a deck'),
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
                Text("Title"),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      hintText: 'Enter a title',
                      labelStyle: TextStyle()),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: RaisedButton(
                    child: Text(
                      "Create deck"
                    ),
                    onPressed: () async {
                      if (_titleController.text.isNotEmpty){
                        await postDeck(_titleController.text);
                        widget.callback();
                        Navigator.pop(context);
                      }
                    },
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