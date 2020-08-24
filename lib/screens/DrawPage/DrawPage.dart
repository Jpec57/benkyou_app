import 'package:benkyou/utils/colors.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "力",
              style: TextStyle(fontSize: 30),
            ),
            Center(
              child: Text("Not implemented yet."),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Color(COLOR_ANTRACITA)),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        "Hello",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
