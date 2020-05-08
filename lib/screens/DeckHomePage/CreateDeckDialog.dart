import 'package:benkyou/models/Deck.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/services/api/deckRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/ConfirmDialog.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateDeckDialog extends StatefulWidget {
  final Function callback;
  final bool isEditing;
  final Deck deck;

  const CreateDeckDialog({Key key, this.callback, this.isEditing = false, this.deck}) : super(key: key);

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
    if (widget.isEditing){
      WidgetsBinding.instance.addPostFrameCallback((_) async{
        _titleController = new TextEditingController(text: widget.deck.title != null ? widget.deck.title : '');
        _descriptionController = new TextEditingController(text: widget.deck.description != null ? widget.deck.description : '');
        setState(() {

        });
      });
    }
  }

  Widget _renderDeleteDeckButton(){
    if (!widget.isEditing){
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        color: Color(COLOR_ORANGE),
        child: Text(
          LocalizationWidget.of(context).getLocalizeValue('delete_deck').toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          if (_formKey.currentState.validate()){
            Get.dialog(ConfirmDialog(
              action: LocalizationWidget.of(context).getLocalizeValue('confirm_delete_deck_mess'),
              positiveCallback: () async {
                await deleteDeck(widget.deck.id);
                Navigator.pushNamed(context, DeckHomePage.routeName);
              },
            ));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        contentPadding: EdgeInsets.all(10.0),
        title: Text(widget.isEditing ? LocalizationWidget.of(context).getLocalizeValue('edit_deck') : LocalizationWidget.of(context).getLocalizeValue('create_deck')),
        content: SingleChildScrollView(
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
                    Text(LocalizationWidget.of(context).getLocalizeValue('title') + '*'),
                    TextFormField(
                      controller: _titleController,
                      validator: (value) {
                        if (value.length < 2) {
                          return LocalizationWidget.of(context).getLocalizeValue('min_2_title');
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: LocalizationWidget.of(context).getLocalizeValue('enter_title'),
                          labelStyle: TextStyle()),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(LocalizationWidget.of(context).getLocalizeValue('description')),
                    ),
                    TextFormField(
                      maxLines: 3,
                      textAlign: TextAlign.justify,
                      controller: _descriptionController,
                      decoration: InputDecoration(
                          hintText: LocalizationWidget.of(context).getLocalizeValue('enter_description'),
                          labelStyle: TextStyle(
                          )),
                    ),

                    _renderDeleteDeckButton(),

                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: RaisedButton(
                        color: Color(COLOR_DARK_BLUE),
                        child: Text(
                          (widget.isEditing ? LocalizationWidget.of(context).getLocalizeValue('update_deck') : LocalizationWidget.of(context).getLocalizeValue('create_deck')).toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()){
                            await postDeck(_titleController.text, _descriptionController.text,
                              deckId: widget.isEditing ? widget.deck.id : null
                            );
                            Navigator.pop(context);
                            if (widget.callback != null){
                              widget.callback();
                            } else {
                              Navigator.pushReplacementNamed(context, DeckHomePage.routeName);
                            }
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
      ),
    );
  }
}
