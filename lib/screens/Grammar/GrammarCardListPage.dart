import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/material.dart';

import 'GrammarHomeHeaderClipper.dart';

class GrammarCardListPage extends StatefulWidget {
  static const routeName = '/grammar-card/list';

  @override
  _GrammarCardListPageState createState() => _GrammarCardListPageState();
}

class _GrammarCardListPageState extends State<GrammarCardListPage> {
  TextEditingController _searchController;
  @override
  void initState() {
    super.initState();
    _searchController = new TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size phoneSize = MediaQuery.of(context).size;

    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Grammar card list'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            ClipPath(
              clipper: GrammarHomeHeaderClipper(),
              child: Container(
                color: Color(COLOR_DARK_BLUE),
                height: phoneSize.height * 0.1,
                child: Align(
                  child: TextFormField(
                    
                    controller: _searchController,
                    decoration: InputDecoration(fillColor: Colors.white),
                  ),
                  alignment: FractionalOffset(0.5, 0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
