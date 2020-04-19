import 'package:benkyou_app/screens/CreateUserPage/CreateUserPage.dart';
import 'package:benkyou_app/screens/HomePage/HomePage.dart';
import 'package:benkyou_app/services/api/userRequests.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginDialog extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => LoginDialogState();

}

class LoginDialogState extends State<LoginDialog>{
  final _formKey = GlobalKey<FormState>();

  TextEditingController _usernameController;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _usernameController = new TextEditingController(text: 'jpec@cap-collectif.com');
    _emailController = new TextEditingController();
    _passwordController = new TextEditingController(text: 'admin');
    _confirmPasswordController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.all(15.0),
      title: Text('Login'),
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
                  Text("Username / email"),
                  TextFormField(
                    controller: _usernameController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your username or email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'Enter your username',
                        labelStyle: TextStyle()),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("Password"),
                        TextFormField(
                          obscureText: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: 'Enter your password',
                              labelStyle: TextStyle()),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: RaisedButton(
                      child: Text(
                          "Not a member yet ? Register here"
                      ),
                      onPressed: () async {
                        Navigator.pushNamed(
                          context,
                          CreateUserPage.routeName,
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: RaisedButton(
                      child: Text(
                          "Login"
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          await loginRequest(_usernameController.text, _passwordController.text);
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            HomePage.routeName,
                          );
                          //TODO show a confirmation and reload
//                          Scaffold
//                              .of(context)
//                              .showSnackBar(SnackBar(content: Text('Welcome back!')));
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