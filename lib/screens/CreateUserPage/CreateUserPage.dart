import 'dart:convert';
import 'dart:io';

import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/services/api/userRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/LoadingCircle.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
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
        new TextEditingController();
    _emailController = new TextEditingController();
    _passwordController = new TextEditingController();
    _confirmPasswordController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(
          title: Text(LocalizationWidget.of(context).getLocalizeValue('create_account')),
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
                    Text(LocalizationWidget.of(context).getLocalizeValue('username')),
                    TextFormField(
                      controller: _usernameController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return LocalizationWidget.of(context).getLocalizeValue('enter_username');
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: LocalizationWidget.of(context).getLocalizeValue('enter_username'),
                          labelStyle: TextStyle()),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(LocalizationWidget.of(context).getLocalizeValue('email')),
                          TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return LocalizationWidget.of(context).getLocalizeValue('enter_email');
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                hintText: LocalizationWidget.of(context).getLocalizeValue('enter_email'),
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
                          Text(LocalizationWidget.of(context).getLocalizeValue('password')),
                          TextFormField(
                            obscureText: true,
                            controller: _passwordController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return LocalizationWidget.of(context).getLocalizeValue('enter_password');
                              }
                              if (value.length < 6) {
                                return LocalizationWidget.of(context).getLocalizeValue('at_least_6_char');
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                hintText: LocalizationWidget.of(context).getLocalizeValue('enter_password'),
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
                          Text(LocalizationWidget.of(context).getLocalizeValue('confirm_password')),
                          TextFormField(
                            obscureText: true,
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return LocalizationWidget.of(context).getLocalizeValue('enter_confirm_password');
                              }
                              if (_passwordController.text != value){
                                return LocalizationWidget.of(context).getLocalizeValue('password_not_match');
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                hintText: LocalizationWidget.of(context).getLocalizeValue('enter_pass_again'),
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
                        color: Color(COLOR_ORANGE),
                        child: Text(LocalizationWidget.of(context).getLocalizeValue('register').toUpperCase(), style: TextStyle(color: Colors.white),),
                        onPressed: () async {
                          _globalError = '';
                          if (_formKey.currentState.validate()) {
                            showLoadingDialog(context);
                            HttpClientResponse response = await registerRequest(_emailController.text, _usernameController.text, _passwordController.text);
                            if (response.statusCode == 201){
                              await loginRequest(_emailController.text, _passwordController.text);
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(
                                context,
                                DeckHomePage.routeName,
                              );
                            } else {
                              Navigator.pop(context);
                              String error = await response.transform(utf8.decoder).join();
                              var jsonCodec = json.decode(error);
                              _globalError = jsonCodec['message'];
                              setState(() {

                              });
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
        ));
  }
}
