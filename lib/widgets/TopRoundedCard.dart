import 'package:flutter/material.dart';

class TopRoundedCard extends StatelessWidget {
  final Widget child;

  const TopRoundedCard({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(50), topLeft: Radius.circular(50)),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(50), topLeft: Radius.circular(50)),
            border: Border.all(color: Colors.white12),
            boxShadow: [],
          ),
          child: child),
    );
  }
}
