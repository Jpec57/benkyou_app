import 'package:benkyou/models/UserCardProcessedInfo.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/screens/DeckPage/DeckPage.dart';
import 'package:benkyou/screens/DeckPage/DeckPageArguments.dart';
import 'package:benkyou/screens/Grammar/GrammarDeckPage.dart';
import 'package:benkyou/screens/Grammar/GrammarDeckPageArguments.dart';
import 'package:benkyou/screens/Grammar/GrammarHomePage.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/LoadingCircle.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LeaveReviewDialog extends StatefulWidget {
  final int deckId;
  final List<UserCardProcessedInfo> processedCards;
  final bool isVocab;

  const LeaveReviewDialog(
      {Key key,
      this.deckId,
      @required this.processedCards,
      this.isVocab = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => LeaveReviewDialogState();
}

class LeaveReviewDialogState extends State<LeaveReviewDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.all(15.0),
      title:
          Text(LocalizationWidget.of(context).getLocalizeValue('stop_review')),
      content: SingleChildScrollView(
        child: GestureDetector(
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
                  Text(
                    LocalizationWidget.of(context)
                        .getLocalizeValue('quit_review_before_end_mess'),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              color: Color(COLOR_DARK_BLUE),
                              child: Text(
                                LocalizationWidget.of(context)
                                    .getLocalizeValue('no')
                                    .toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: RaisedButton(
                              color: Color(COLOR_ORANGE),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                LocalizationWidget.of(context)
                                    .getLocalizeValue('yes')
                                    .toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                showLoadingDialog(context);
                                await postReview(widget.processedCards);
                                Navigator.pop(context);
                                if (widget.isVocab) {
                                  if (widget.deckId != null) {
                                    Navigator.pushReplacementNamed(
                                        context, DeckPage.routeName,
                                        arguments:
                                            DeckPageArguments(widget.deckId));
                                  } else {
                                    Navigator.pushReplacementNamed(
                                        context, DeckHomePage.routeName);
                                  }
                                } else {
                                  if (widget.deckId != null) {
                                    Navigator.pushReplacementNamed(
                                        context, GrammarDeckPage.routeName,
                                        arguments: GrammarDeckPageArguments(
                                            deckId: widget.deckId));
                                  } else {
                                    Navigator.pushReplacementNamed(
                                        context, GrammarHomePage.routeName);
                                  }
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
