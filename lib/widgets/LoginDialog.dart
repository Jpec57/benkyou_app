import 'package:benkyou/screens/CreateUserPage/CreateUserPage.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/services/api/userRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/LoadingCircle.dart';
import 'package:benkyou/widgets/LoginWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Localization.dart';

class LoginDialog extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => LoginDialogState();

}

class LoginDialogState extends State<LoginDialog>{
  final _formKey = GlobalKey<FormState>();

  TextEditingController _usernameController;
  TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = new TextEditingController();
    _passwordController = new TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String previousUsername = sharedPreferences.get('previousUsername');
      _usernameController = new TextEditingController(text: previousUsername != null ? previousUsername : '');
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.all(15.0),
      title: Text(LocalizationWidget.of(context).getLocalizeValue('login')),
      content: LoginWidget(),
    );
  }

}