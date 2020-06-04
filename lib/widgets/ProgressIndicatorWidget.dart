import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => ProgressIndicatorWidgetState();
}

class ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget>{
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: Container(
          height: 20,
          width: 100,
          color: Colors.red,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                color: Colors.grey,
                width: 50,
                height: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

}