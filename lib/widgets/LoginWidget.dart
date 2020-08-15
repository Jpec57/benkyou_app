import 'package:benkyou/screens/CreateUserPage/CreateUserPage.dart';
import 'package:benkyou/screens/HomePage/HomePage.dart';
import 'package:benkyou/services/api/userRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/LoadingCircle.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController;
  TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = new TextEditingController();
    _passwordController = new TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String previousUsername = sharedPreferences.get('previousUsername');
      _usernameController = new TextEditingController(
          text: previousUsername != null ? previousUsername : '');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(LocalizationWidget.of(context)
                      .getLocalizeValue('user_email')),
                  TextFormField(
                    controller: _usernameController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return LocalizationWidget.of(context)
                            .getLocalizeValue('enter_username_email');
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: LocalizationWidget.of(context)
                            .getLocalizeValue('enter_username'),
                        labelStyle: TextStyle()),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(LocalizationWidget.of(context)
                            .getLocalizeValue('password')),
                        TextFormField(
                          obscureText: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return LocalizationWidget.of(context)
                                  .getLocalizeValue('enter_password');
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: LocalizationWidget.of(context)
                                  .getLocalizeValue('enter_password'),
                              labelStyle: TextStyle()),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: RaisedButton(
                      color: Color(COLOR_DARK_BLUE),
                      child: Text(
                        LocalizationWidget.of(context)
                            .getLocalizeValue('login')
                            .toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          showLoadingDialog(context);
                          bool res = await loginRequest(
                              _usernameController.text,
                              _passwordController.text);
                          if (!res) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(
                              context,
                              HomePage.routeName,
                            );
                            SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            String username =
                                sharedPreferences.getString('username');
                            Get.snackbar(
                                LocalizationWidget.of(context)
                                        .getLocalizeValue('welcome_back') +
                                    ' $username!',
                                '久しぶりだな麦わら',
                                snackPosition: SnackPosition.BOTTOM);
                          }
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: RaisedButton(
                      color: Color(COLOR_ORANGE),
                      child: Text(
                        LocalizationWidget.of(context)
                            .getLocalizeValue('not_member_yet')
                            .toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        Navigator.pushNamed(
                          context,
                          CreateUserPage.routeName,
                        );
                      },
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
