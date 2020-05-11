import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget{
  static const routeName = '/my-profile';

  @override
  State<StatefulWidget> createState() => ProfilePageState();

}

class ProfilePageState extends State<ProfilePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationWidget.of(context).getLocalizeValue('my_profile')),
      ),
      drawer: MainDrawer(),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("lib/imgs/japan.png"),
                    fit: BoxFit.cover)
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}