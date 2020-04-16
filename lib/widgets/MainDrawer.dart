import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/DeckPage/DeckPage.dart';
import '../screens/DeckPage/DeckPageArguments.dart';
import '../screens/HomePage/HomePage.dart';

class MainDrawer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => MainDrawerState();
}

class MainDrawerState extends State<MainDrawer>{
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Colors.blue,
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
            title: Text('Item 2'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }

}