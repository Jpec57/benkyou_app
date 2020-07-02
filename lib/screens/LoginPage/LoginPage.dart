import 'package:benkyou/screens/CreateUserPage/CreateUserPage.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/services/api/userRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/LoadingCircle.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/LoginWidget.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget{
  static const routeName = '/login';

  @override
  State<StatefulWidget> createState() => LoginPageState();

}

class LoginPageState extends State<LoginPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        leading: Container(),
      ),
      body: GestureDetector(
        onTap: (){
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 30, right: 30),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image(
                          image:AssetImage("lib/imgs/app_icon.png"),
                        height: 100,
                      ),
                      Expanded(child: Center(child: Text('Benkyou', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),))),
                    ],
                  ),
                ),
                LoginWidget()
              ],
            ),
          ),
        ),
      ),
    );
  }
}