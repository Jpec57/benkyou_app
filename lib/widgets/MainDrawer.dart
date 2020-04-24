import 'package:benkyou/screens/BrowseDeckPage/BrowseDeckPage.dart';
import 'package:benkyou/screens/ListCardPage/ListCardPage.dart';
import 'package:benkyou/screens/ListCardPage/ListCardPageArguments.dart';
import 'package:benkyou/services/api/userRequests.dart';
import 'package:benkyou/widgets/LoadingCircle.dart';
import 'package:benkyou/widgets/LoginDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/HomePage/HomePage.dart';

class MainDrawer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => MainDrawerState();
}

class MainDrawerState extends State<MainDrawer>{
  Future<bool> isUserConnected;

  @override
  void initState() {
    super.initState();
    isUserConnected = _isUserConnected();
  }

  Future<bool> _isUserConnected() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userId = sharedPreferences.getInt('userId');
    return userId != null;
  }

  Widget _renderLoginTile() {
    return FutureBuilder(
      future: isUserConnected,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch(snapshot.connectionState){
          case ConnectionState.waiting:
            return ListTile(
              title: Text('Loading...'),
            );
          case ConnectionState.done:
            if (snapshot.hasData && snapshot.data){
              return ListTile(
                title: Text('Log out'),
                onTap: () async {
                  showLoadingDialog(context);
                  await logoutRequest();
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    HomePage.routeName,
                  );
                },
              );
            }
            return ListTile(
              title: Text('Log in'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context, builder: (BuildContext context) => LoginDialog());
              },
            );
          default:
            return ListTile(
              title: Text('Log in'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context, builder: (BuildContext context) => LoginDialog());
                // Update the state of the app.
                // ...
              },
            );
        }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Align(
              alignment: Alignment.bottomLeft,
                child: FutureBuilder(
                  future: isUserConnected,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    switch (snapshot.connectionState){
                      case ConnectionState.done:
                        if (snapshot.hasData){
                          return Text(
                            snapshot.data ? '今日は！' : 'ようこそ!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 3.0,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          );
                        }
                        return Text(
                          'ようこそ!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        );
                      default:
                        return Text(
                          'ようこそ!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        );
                    }
                  },
                )),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("lib/imgs/japan.png"),
                    fit: BoxFit.cover)
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              Navigator.pushNamed(
                context,
                HomePage.routeName,
              );
            },
          ),
          ListTile(
            title: Text('Browse decks'),
            onTap: () {
              Navigator.pushNamed(
                context,
                BrowseDeckPage.routeName,
              );
            },
          ),
          ListTile(
            title: Text('My cards'),
            onTap: () {
              Navigator.pushNamed(
                context,
                ListCardPage.routeName,
                arguments: ListCardPageArguments()
              );
            },
          ),
          _renderLoginTile(),
        ],
      ),
    );
  }

}