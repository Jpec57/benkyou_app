import 'package:benkyou_app/models/UserCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget{
  static const routeName = '/review';

  final List<UserCard> cards;

  const ReviewPage({Key key, @required this.cards}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review'),
      ),
      body: Container(
        child: Center(
          child: Text("Review page"),
        ),
      ),
    );
  }
}