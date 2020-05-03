import 'package:benkyou/screens/DeckHomePage/DeckHomePage.dart';
import 'package:benkyou/screens/DialogPage/DialogPage.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget{
  static const routeName = '/';

  @override
  State<StatefulWidget> createState() => HomePageState();

}

class HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Benkyou'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("lib/imgs/blackboard.png"),
                              fit: BoxFit.cover)
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(35.0),
                          child: Center(child: Text('BLABLAzelnf zelnfzenfkzenfl zenfelz eknbbikjk l', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20))),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.of(context).pushNamed(DeckHomePage.routeName);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(COLOR_ORANGE),
                      ),
                      child: Center(
                        child: Text('Review decks'.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.of(context).pushNamed(DialogPage.routeName);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(COLOR_DARK_BLUE),
                      ),
                      child: Center(
                        child: Text('Speak'.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}