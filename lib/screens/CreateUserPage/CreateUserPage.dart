import 'dart:convert';
import 'dart:io';

import 'package:benkyou_app/screens/HomePage/HomePage.dart';
import 'package:benkyou_app/services/api/userRequests.dart';
import 'package:benkyou_app/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateUserPage extends StatefulWidget {
  static String routeName = '/create/user';

  @override
  State<StatefulWidget> createState() => CreateUserPageState();
}

class CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  String _globalError = '';

  TextEditingController _usernameController;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _usernameController =
        new TextEditingController(text: 'Jpec');
    _emailController = new TextEditingController(text: 'abc@hotmail.fr');
    _passwordController = new TextEditingController(text: 'iiiiii');
    _confirmPasswordController = new TextEditingController(text: 'iiiiii');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(
          title: Text('Create account'),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("Username"),
                    TextFormField(
                      controller: _usernameController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your username';
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
                          Text("Email"),
                          TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your email.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                hintText: 'Enter your email',
                                labelStyle: TextStyle()),
                          ),
                        ],
                      ),
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
                              if (value.length < 6) {
                                return 'Your password must use least 6 characters';
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
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("Confirm password"),
                          TextFormField(
                            obscureText: true,
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (_passwordController.text != value){
                                return "Passwords don't match";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                hintText: 'Enter your password again',
                                labelStyle: TextStyle()),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Text(_globalError,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: RaisedButton(
                        child: Text("Register"),
                        onPressed: () async {
                          _globalError = '';
                          if (_formKey.currentState.validate()) {
                            HttpClientResponse response = await registerRequest(_emailController.text, _usernameController.text, _passwordController.text);
                            if (response.statusCode == 201){
                              await loginRequest(_emailController.text, _passwordController.text);
                              Navigator.pushNamed(
                                context,
                                HomePage.routeName,
                              );
                            } else {
                              String error = await response.transform(utf8.decoder).join();
                              var jsonCodec = json.decode(error);
                              _globalError = jsonCodec['message'];
                            }
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
        ));
  }
}
