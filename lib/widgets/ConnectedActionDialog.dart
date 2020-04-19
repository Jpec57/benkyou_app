import 'package:benkyou_app/screens/CreateUserPage/CreateUserPage.dart';
import 'package:benkyou_app/widgets/LoginDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConnectedActionDialog extends StatelessWidget{
  final String action;

  const ConnectedActionDialog({Key key, this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.all(15.0),
      title: Text('You must be connected.'),
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
                child: Text("Login or register $action", textAlign: TextAlign.center,),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text('Login'),
                      onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                          context: context, builder: (BuildContext context) => LoginDialog());
                    },),
                  ),
                  Expanded(
                    child: RaisedButton(
                      child: Text('Register'),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          CreateUserPage.routeName,
                        );
                      },),
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