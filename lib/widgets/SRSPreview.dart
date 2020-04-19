import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SRSPreview extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => SRSPreviewState();

}

class SRSPreviewState extends State<SRSPreview>{
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      itemCount: 5,
      itemBuilder: (BuildContext context, int i) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 25.0,
              height: 25.0,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                  "resources/icon/app_icon.png"),
            ),
            Text(
              "Coucou",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            Text(
              "NUmber",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
          ],
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }

}