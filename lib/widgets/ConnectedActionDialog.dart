import 'package:benkyou/screens/CreateUserPage/CreateUserPage.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/LoginDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Localization.dart';

class ConnectedActionDialog extends StatelessWidget{
  final String action;

  const ConnectedActionDialog({Key key, this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.all(15.0),
      title: Text(LocalizationWidget.of(context).getLocalizeValue('must_be_connected_message')),
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
                child: Text(LocalizationWidget.of(context).getLocalizeValue('login_or_register') + " $action", textAlign: TextAlign.center,),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: RaisedButton(
                        color: Color(COLOR_DARK_BLUE),
                        child: Text(LocalizationWidget.of(context).getLocalizeValue('register'),
                          style: TextStyle(
                              color: Colors.white
                          ),),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            CreateUserPage.routeName,
                          );
                        },),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: RaisedButton(
                        color: Color(COLOR_ORANGE),
                        child: Text(LocalizationWidget.of(context).getLocalizeValue('login'),
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                              context: context, builder: (BuildContext context) => LoginDialog());
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