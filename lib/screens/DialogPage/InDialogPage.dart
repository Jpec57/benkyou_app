import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InDialogPage extends StatefulWidget {
  static const routeName = '/dialog/in';

  @override
  State<StatefulWidget> createState() => InDialogPageState();
}

class InDialogPageState extends State<InDialogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Dialog'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(

              child: Center(
                child: Image.asset('lib/imgs/app_icon.png', height: MediaQuery.of(context).size.width * 0.45,),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("lib/imgs/japan.png"),
                    fit: BoxFit.cover)
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Color(COLOR_GREY),
            ),
          )
        ],
      ),
    );
  }
}
