import 'package:benkyou_app/services/api/userRequests.dart';
import 'package:benkyou_app/widgets/LoginDialog.dart';
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
          _renderLoginTile(),
        ],
      ),
    );
  }

}