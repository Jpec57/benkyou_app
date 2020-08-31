import 'package:benkyou/screens/DeckHomePage/CreateDeckDialog.dart';
import 'package:benkyou/services/api/deckRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/Deck.dart';
import '../DeckPage/DeckPage.dart';
import '../DeckPage/DeckPageArguments.dart';

class DeckContainer extends StatefulWidget {
  final Deck deck;

  const DeckContainer({Key key, @required this.deck}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DeckContainerState();
}

class _DeckContainerState extends State<DeckContainer> {
  Future<ImageProvider> _deckCover;

  @override
  void initState() {
    super.initState();
    _deckCover = getBackgroundImageIfExisting();
  }

  Future<ImageProvider> getBackgroundImageIfExisting() async {
    return await getDeckCover(widget.deck.id, widget.deck.cover);
  }

  @override
  Widget build(BuildContext context) {
    Widget defaultDeckWidget = Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Color(COLOR_MID_DARK_GREY)),
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          widget.deck.title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      )),
    );
    return GestureDetector(
        onLongPress: () {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  CreateDeckDialog(isEditing: true, deck: widget.deck));
        },
        onTap: () {
          Navigator.pushNamed(
            context,
            DeckPage.routeName,
            arguments: DeckPageArguments(widget.deck.id),
          );
        },
        child: FutureBuilder(
          future: _deckCover,
          builder: (BuildContext context,
              AsyncSnapshot<ImageProvider> deckCoverSnap) {
            switch (deckCoverSnap.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.done:
                if (deckCoverSnap.hasData && deckCoverSnap.data != null) {
                  return Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      fit: BoxFit.cover,
                      image: deckCoverSnap.data,
                    )),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.deck.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.grey,
                              ),
                            ],
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                  );
                }
                return defaultDeckWidget;
              case ConnectionState.none:
                return defaultDeckWidget;
              default:
                return defaultDeckWidget;
            }
          },
        ));
  }
}
