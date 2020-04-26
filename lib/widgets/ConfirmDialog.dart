import 'package:benkyou/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget{
  final String action;
  final Function positiveCallback;
  final Function negativeCallback;

  const ConfirmDialog({Key key, @required this.action, @required this.positiveCallback, this.negativeCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.all(10.0),
      title: Text('Confirm action'),
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
                Text(action, textAlign: TextAlign.center,),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: RaisedButton(
                            color: Color(COLOR_DARK_BLUE),
                            child: Text('NO',
                              style: TextStyle(
                                  color: Colors.white
                              ),),
                            onPressed: () {
                              Navigator.pop(context);
                              if (negativeCallback != null){
                                negativeCallback();
                              }
                            },),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: RaisedButton(
                            color: Color(COLOR_ORANGE),
                            child: Text('YES',
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              positiveCallback();
                            },),
                        ),
                      ),
                    ],
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