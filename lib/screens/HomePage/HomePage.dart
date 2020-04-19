import 'package:benkyou_app/screens/HomePage/CreateDeckDialog.dart';
import 'package:benkyou_app/utils/colors.dart';
import 'package:benkyou_app/widgets/ConnectedActionDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/Deck.dart';
import '../../services/api/deckRequests.dart';
import '../../widgets/MainDrawer.dart';
import 'DeckContainer.dart';

class HomePage extends StatefulWidget{
  static const routeName = '/';

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>{
  Future<List<Deck>> personalDecks;

  @override
  void initState() {
    super.initState();
    personalDecks = getPersonalDecks();
  }

  void _createNewDeck() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.get('userId') == null){
      showDialog(
          context: context, builder: (BuildContext context) => ConnectedActionDialog(action: "to create a deck.",));
      return;
    }
    showDialog(
        context: context, builder: (BuildContext context) => CreateDeckDialog(callback: this.reloadDecks));
  }

  void reloadDecks(){
    setState(() {
      personalDecks = getPersonalDecks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Benkyou'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder(
          future: personalDecks,
          builder: (BuildContext context, AsyncSnapshot<List<Deck>> deckSnapshot) {
            if (deckSnapshot.hasData){
              if (deckSnapshot.data.length == 0){
                return Center(child: Text('No deck available. Please create one.'));
              }
              return GridView.count(
                  crossAxisCount: 2,
                  key: ValueKey('deck-grid'),
                  children: List.generate(deckSnapshot.data.length, (index) {
                    Deck deck = deckSnapshot.data[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DeckContainer(
                        deck: deck,
                      ),
                    );
                  }));
          }
            return Center(child: Text('No deck available. Please create one.'));
        })
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewDeck,
        backgroundColor: Color(COLOR_ORANGE),
        tooltip: 'Add a deck',
        child: Icon(Icons.add),
      ),
    );
  }

}