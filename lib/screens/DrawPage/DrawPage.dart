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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Draw kanji"),
      ),
      drawer: MainDrawer(),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text("Not implemented yet."),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: size.width * 0.8,
                  height: size.width * 0.8,
                  decoration: BoxDecoration(color: Color(COLOR_ANTRACITA)),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          "力",
                          style: TextStyle(fontSize: 70, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
