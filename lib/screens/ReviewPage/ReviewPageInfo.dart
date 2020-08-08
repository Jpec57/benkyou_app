import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReviewPageInfo extends StatelessWidget {
  final int nbSuccess;
  final int nbErrors;
  final int remainingNumber;
  final bool isAnswerVisible;

  const ReviewPageInfo(
      {Key key,
      @required this.nbSuccess,
      @required this.nbErrors,
      @required this.remainingNumber,
      @required this.isAnswerVisible})
      : super(key: key);

  String getSuccessPercent() {
    if (nbSuccess == 0 && nbErrors == 0) {
      return "100";
    }
    return (nbSuccess * 100 / (nbSuccess + nbErrors)).toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${getSuccessPercent()}%",
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(
                    Icons.poll,
                    size: 20,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "$nbSuccess",
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(
                      Icons.done,
                      size: 20,
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${remainingNumber - (isAnswerVisible ? 1 : 0)}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(
                    Icons.inbox,
                    size: 20,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      alignment: Alignment.topRight,
    );
  }
}
