import 'package:benkyou_app/models/UserCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SRSPreview extends StatefulWidget {
  final List<UserCard> cards;

  const SRSPreview({Key key, @required this.cards}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SRSPreviewState();
}

class SRSLevel {
  String title;
  int num = 0;

  SRSLevel(this.title);
}

class SRSPreviewState extends State<SRSPreview> {

  @override
  void initState() {
    super.initState();
  }

  List<SRSLevel> _getSRSLevelArray() {
    List<SRSLevel> srsLevels = [
      SRSLevel("Rookie"),
      SRSLevel("Intermediary"),
      SRSLevel("Master"),
      SRSLevel("Veteran"),
      SRSLevel("Pro"),
    ];
    for (UserCard card in widget.cards) {
      print(card.toString());
      switch (card.lvl) {
        case 0:
        case 1:
        case 2:
          srsLevels[0].num++;
          break;
        case 3:
        case 4:
          srsLevels[1].num++;
          break;
        case 5:
        case 6:
          srsLevels[2].num++;
          break;
        case 7:
        case 8:
          srsLevels[3].num++;
          break;
        case 9:
          srsLevels[4].num++;
          break;
        default:
          srsLevels[0].num++;
          break;
      }
    }
    return srsLevels;
  }

  @override
  Widget build(BuildContext context) {
    List<SRSLevel> srsLevels = _getSRSLevelArray();
    return FractionallySizedBox(
      widthFactor: 0.75,
      child: Card(
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          itemCount: srsLevels.length,
          itemBuilder: (BuildContext context, int i) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 25.0,
                    height: 25.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset("lib/imgs/app_icon.png"),
                  ),
                  Text(
                    srsLevels[i].title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25),
                  ),
                  Text(
                    "${srsLevels[i].num}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
        ),
      ),
    );
  }
}
