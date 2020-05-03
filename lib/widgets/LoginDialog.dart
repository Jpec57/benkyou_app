import 'package:benkyou/screens/CreateUserPage/CreateUserPage.dart';
import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/services/api/userRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/LoadingCircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      title: Text('Login'),
      content: SingleChildScrollView(
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
                        color: Color(COLOR_DARK_BLUE),
                        child: Text(
                            "Login".toUpperCase(),
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            showLoadingDialog(context);
                            bool res = await loginRequest(_usernameController.text, _passwordController.text);
                            Navigator.pop(context);
                            if (!res){
                              Get.snackbar('Error', 'An error occurred. Please contact the support for any help.', snackPosition: SnackPosition.BOTTOM);
                            } else {
                              Navigator.pushReplacementNamed(
                                context,
                                DeckHomePage.routeName,
                              );
                              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                              String username = sharedPreferences.getString('username');
                              Get.snackbar('Welcome back $username!', '久しぶりだな麦わら', snackPosition: SnackPosition.BOTTOM);}
                          }
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: RaisedButton(
                        color: Color(COLOR_ORANGE),
                        child: Text(
                          "Not a member yet ? Register here".toUpperCase(),
                          style: TextStyle(
                              color: Colors.white
                          ),
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
      ),
    );
  }

}