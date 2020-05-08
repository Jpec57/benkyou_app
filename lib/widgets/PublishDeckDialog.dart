import 'package:benkyou/models/Deck.dart';
import 'package:benkyou/screens/DeckPage/DeckPage.dart';
import 'package:benkyou/screens/DeckPage/DeckPageArguments.dart';
import 'package:benkyou/services/api/deckRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Localization.dart';

class PublishDeckDialog extends StatefulWidget{
  final Deck deck;

  const PublishDeckDialog({Key key, @required this.deck}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PublishDeckDialogState();

}

class PublishDeckDialogState extends State<PublishDeckDialog>{

  String _renderContent(){
    return widget.deck.isPublic ?
    LocalizationWidget.of(context).getLocalizeValue('confirm_private_deck')
        :
    LocalizationWidget.of(context).getLocalizeValue('confirm_publish_deck');
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.all(15.0),
      title: Text(widget.deck.isPublic ? LocalizationWidget.of(context).getLocalizeValue('unpublish_your_deck') : LocalizationWidget.of(context).getLocalizeValue('publish_your_deck')),
      content: Container(
        width: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 30),
                child: Text(_renderContent(), textAlign: TextAlign.center,),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: RaisedButton(
                        color: Color(COLOR_ORANGE),
                        child: Text(LocalizationWidget.of(context).getLocalizeValue('cancel').toUpperCase(),
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: RaisedButton(
                        color: Color(COLOR_DARK_BLUE),
                        child: Text((widget.deck.isPublic ? LocalizationWidget.of(context).getLocalizeValue('unpublish'): LocalizationWidget.of(context).getLocalizeValue('publish') ).toUpperCase(),
                          style: TextStyle(
                              color: Colors.white
                          ),),
                        onPressed: () async {
                          await publishDeck(widget.deck.id, !widget.deck.isPublic);
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(
                            context,
                            DeckPage.routeName,
                            arguments: DeckPageArguments(
                                widget.deck.id
                            ),
                          );

                        },),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}