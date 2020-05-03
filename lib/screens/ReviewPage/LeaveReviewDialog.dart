import 'package:benkyou/models/UserCardProcessedInfo.dart';
import 'package:benkyou/screens/DeckPage/DeckPage.dart';
import 'package:benkyou/screens/DeckPage/DeckPageArguments.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/services/api/cardRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/LoadingCircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LeaveReviewDialog extends StatefulWidget{
  final int deckId;
  final List<UserCardProcessedInfo> processedCards;

  const LeaveReviewDialog({Key key, this.deckId, @required this.processedCards}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LeaveReviewDialogState();

}

class LeaveReviewDialogState extends State<LeaveReviewDialog>{
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.all(15.0),
      title: Text('Stop review'),
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
                  Text("Do you want to leave the review ? Your progression will be saved.", textAlign: TextAlign.center,),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: RaisedButton(
                              color: Color(COLOR_DARK_BLUE),
                              child: Text(
                                "No".toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white
                                ),
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
                              child: Text(
                                "Yes".toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                              onPressed: () async {
                                showLoadingDialog(context);
                                await postReview(widget.processedCards);
                                Navigator.pop(context);
                                if (widget.deckId != null){
                                  Navigator.pushReplacementNamed(context, DeckPage.routeName, arguments: DeckPageArguments(widget.deckId));
                                } else {
                                  Navigator.pushReplacementNamed(context, DeckHomePage.routeName);
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