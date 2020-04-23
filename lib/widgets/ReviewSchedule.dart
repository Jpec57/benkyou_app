import 'package:benkyou/models/TimeBar.dart';
import 'package:benkyou/models/UserCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReviewSchedule extends StatefulWidget {
  final double size;
  final List<Color> colors;
  final List<UserCard> cards;

  const ReviewSchedule(
      {Key key,
        this.size = 100,
        this.colors = const [Colors.red],
        @required this.cards})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ReviewScheduleState();
}

class ReviewScheduleState extends State<ReviewSchedule> {
  bool isWholeWeek = false;
  Future<List<List<Widget>>> _timelineSchedule;


  @override
  void initState() {
    super.initState();
    _timelineSchedule = getTimelineSchedule();
  }

  Widget _getLabel(String title, {int index = 0}) {
    return Expanded(
      child: Container(
        child: Align(
            alignment: Alignment.topCenter,
            child: Visibility(
              visible: index % 3 == 0,
              child: Text(
                "$title",
                style: TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            )),
      ),
    );
  }

  Widget _getColumn(double current, double max, int index) {
    if (max <= 0.0){
      max = 1;
    }
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          child: ClipPath(
            clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(3.0),
                      topRight: Radius.circular(3.0),
                    ))),
            child: Container(
              child: Center(
                child: Text(
                  "${current.toInt()}",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              decoration: BoxDecoration(
                  color: widget.colors[index % widget.colors.length],
                  border: Border(
                      left: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
                      right:
                      BorderSide(width: 1.0, color: Color(0xFFFF000000)))),
            ),
          ),
          height: widget.size * (current / max),
        ),
      ),
    );
  }

  String getDate(int time){
    return DateTime.fromMillisecondsSinceEpoch(time).toIso8601String();
  }

  List<TimeBar> _getBarsFromCards(DateTime end){
    List<TimeBar> bars = [];
    for (UserCard userCard in widget.cards){
      int cardTimestamp = DateTime.parse(userCard.nextAvailable).millisecondsSinceEpoch;

      if (cardTimestamp > end.millisecondsSinceEpoch){
        break;
      }
      bars.add(TimeBar(1, cardTimestamp));
    }
    return bars;
  }

  Future<List<List<Widget>>> getTimelineSchedule() async {
    List<Widget> columns = new List();
    List<Widget> labels = new List();
    DateTime start = DateTime.now();
    DateTime tmp = start;
    Duration interval;
    DateTime end;
    int sum;
    //Use to set max height
    int maxSum = 0;

    //We get the period
    if (this.isWholeWeek){
      interval = Duration(days: 1);
      end = start.add(Duration(days: 14));
    } else {
      interval = Duration(hours: 1);
      end = start.add(Duration(hours: 12));
    }
    //We get the current round hour
    start = start.subtract(Duration(hours: start.hour, minutes: start.minute, seconds: start.second));

    if (this.isWholeWeek){
      tmp = start;
    }

    List<TimeBar> bars = _getBarsFromCards(end);
    int i = 0;
    int j = 0;

    for (TimeBar card in bars){
      if (maxSum < card.num){
        maxSum = card.num;
      }
    }
    //To prevent from having two bars for same day
    if (this.isWholeWeek){
      tmp = tmp.add(Duration(days: 1));
    }
    while (tmp.millisecondsSinceEpoch < end.millisecondsSinceEpoch){
      sum = 0;
      while (i < bars.length  && bars[i].nextAvailable <= tmp.millisecondsSinceEpoch){
        sum += bars[i].num;
        i++;
      }
      columns.add(_getColumn(sum.toDouble(), maxSum.toDouble(), j));
      labels.add(_getLabel(this.isWholeWeek ? "${tmp.month}/${tmp.day}" : "${tmp.hour}h", index: j));
      tmp = tmp.add(interval);
      j++;
    }
    return [columns, labels];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        setState(() {
          isWholeWeek = !isWholeWeek;
          _timelineSchedule = getTimelineSchedule();
        });
      },
      child: Container(
        child: FutureBuilder(
            future: _timelineSchedule,
            builder: (BuildContext context, AsyncSnapshot<List<List<Widget>>> timelineSnapshot) {
              switch (timelineSnapshot.connectionState){
                case ConnectionState.done:
                  if (timelineSnapshot.hasData  && timelineSnapshot.data.length > 0){
                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(width: 1.0, color: Color(0xFFCDCDCD)),
                                    left: BorderSide(width: 1.2, color: Color(0xFF696969)),
                                    bottom:
                                    BorderSide(width: 1.2, color: Color(0xFF696969)))),
                            height: widget.size,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: timelineSnapshot.data[0],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Container(
                            child: Row(
                              children: timelineSnapshot.data[1],
                            ),
                          ),
                        )
                      ],
                    );
                  }
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                  );
                default:
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                  );
              }
            }
        ),
      ),
    );
  }
}