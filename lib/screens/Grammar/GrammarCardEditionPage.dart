import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/material.dart';

class GrammarCardEditionPage extends StatefulWidget {
  static const routeName = '/grammar-card/edit';
  final int cardId;

  const GrammarCardEditionPage({Key key, @required this.cardId})
      : super(key: key);

  @override
  _GrammarCardEditionPageState createState() => _GrammarCardEditionPageState();
}

class _GrammarCardEditionPageState extends State<GrammarCardEditionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      body: Container(),
    );
  }
}
