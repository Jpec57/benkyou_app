import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/material.dart';

class DrawPage extends StatefulWidget {
  static const routeName = '/draw';

  @override
  _DrawPageState createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
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
      appBar: AppBar(
        title: Text("Draw kanji"),
      ),
      drawer: MainDrawer(),
      body: Container(
        child: Center(
          child: Text("Not implemented yet."),
        ),
      ),
    );
  }
}
