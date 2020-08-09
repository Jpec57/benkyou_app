import 'dart:io';

import 'package:benkyou/screens/DeckHomePage/CreateDeckDialog.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
  Future<File> _deckCover;

  @override
  void initState() {
    super.initState();
    _deckCover = getBackgroundImageIfExisting();
  }

  Future<File> getBackgroundImageIfExisting() async {
    final String path = (await getApplicationDocumentsDirectory()).path;
    File file = File('$path/DeckCover-${widget.deck.id}.png');
    bool isExisting = await file.exists();
    if (isExisting) {
      return file;
    }
    return null;
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
          builder: (BuildContext context, AsyncSnapshot<File> deckCoverSnap) {
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
                      image: FileImage(deckCoverSnap.data),
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
