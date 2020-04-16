import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  void _createNewDeck() async {

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
          future: getPersonalDecks(),
          builder: (BuildContext context, AsyncSnapshot<List<Deck>> deckSnapshot) {
            if (deckSnapshot.hasData){
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
            return Center(child: Text("No deck available."));
        })
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewDeck,
        backgroundColor: Colors.orange,
        tooltip: 'Add a deck',
        child: Icon(Icons.add),
      ),
    );
  }

}