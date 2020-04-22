import 'package:benkyou_app/models/Deck.dart';
import 'package:benkyou_app/services/api/deckRequests.dart';
import 'package:benkyou_app/utils/colors.dart';
import 'package:benkyou_app/widgets/DeckCardList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreviewPublicDeckPage extends StatefulWidget{
  static const routeName = '/preview/deck';
  final int deckId;

  const PreviewPublicDeckPage({Key key, @required this.deckId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PreviewPublicDeckPageState();
}

class PreviewPublicDeckPageState extends State<PreviewPublicDeckPage>{
  Future<Deck> deckFuture;


  @override
  void initState() {
    super.initState();
    deckFuture = getDeck(widget.deckId);
  }

  Widget _renderDescription(Deck deck){
    if (deck.description != null){
      return Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 18.0),
        child: Text(deck.description, style: TextStyle(
          fontSize: 17,
          shadows: <Shadow>[
            Shadow(
              offset: Offset(2.0, 2.0),
              blurRadius: 3.0,
              color: Colors.grey,
            ),
          ],
        ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview deck'),
      ),
      body: FutureBuilder(
        future: deckFuture,
        builder: (BuildContext context, AsyncSnapshot deckSnapshot) {
          switch (deckSnapshot.connectionState){
            case ConnectionState.waiting:
              return Center(child: Text("Loading..."),);
            case ConnectionState.done:
              if (deckSnapshot.hasData){
                Deck deck = deckSnapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(

                          image: DecorationImage(
                              colorFilter:
                              ColorFilter.mode(Colors.black.withOpacity(0.5),
                                  BlendMode.dstATop),
                              image: AssetImage("lib/imgs/japan.png"),
                              fit: BoxFit.cover)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(deck.title, style: TextStyle(
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 3.0,
                                        color: Colors.grey,
                                      ),
                                    ],
                                    fontSize: 26
                                ),
                                  textAlign: TextAlign.center,
                                ),
                                GestureDetector(
                                  onTap: (){

                                  },
                                  child: Text("by ${deck.author.username}", style: TextStyle(
                                      shadows: <Shadow>[
                                        Shadow(
                                          offset: Offset(2.0, 2.0),
                                          blurRadius: 3.0,
                                          color: Colors.grey,
                                        ),
                                      ],
                                      fontSize: 14,
                                    fontStyle: FontStyle.italic
                                  ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                _renderDescription(deck)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              color: Color(COLOR_DARK_BLUE),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                child: Text('List of cards in deck', textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20, color: Colors.white),),
                              ),
                            ),
                            Expanded(child: Container(
                                color: Color(COLOR_DARK_BLUE),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12, right: 12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0)),
                                      color: Colors.white,
                                    ),
                                      child: DeckCardList(cards: deck.cards)),
                                ))),
                          ],
                        )
                    ),
                    GestureDetector(
                      onTap: (){


                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                          color: Color(COLOR_ORANGE),
                          child: Center(child:
                          Text("Import this deck".toUpperCase(),
                            style:
                            TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                            ,))
                      ),
                    ),
                  ],
                );
              }
              return Center(child: Text("No data."),);
            default:
              return Center(child: Text("No data."),);
          }
      },
      ),
    );
  }

}