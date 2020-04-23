import 'package:benkyou/services/api/deckRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:flutter/material.dart';

class CreateDeckDialog extends StatefulWidget {
  final Function callback;

  const CreateDeckDialog({Key key, this.callback}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CreateDeckDialogState();
}

class CreateDeckDialogState extends State<CreateDeckDialog> {
  TextEditingController _titleController;
  TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = new TextEditingController();
    _descriptionController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.all(10.0),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Title*"),
                  TextFormField(
                    controller: _titleController,
                    validator: (value) {
                      if (value.length < 2) {
                        return 'Your title must use at least 2 characters.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'Enter a title',
                        labelStyle: TextStyle()),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text("Description"),
                  ),
                  TextFormField(
                    maxLines: 3,
                    textAlign: TextAlign.justify,
                    controller: _descriptionController,
                    decoration: InputDecoration(
                        hintText: 'Enter a description',
                        labelStyle: TextStyle(
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: RaisedButton(
                      color: Color(COLOR_DARK_BLUE),
                      child: Text(
                        "Create deck",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()){
                          await postDeck(_titleController.text, _descriptionController.text);
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
      ),
    );
  }
}
