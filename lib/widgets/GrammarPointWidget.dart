import 'package:benkyou/models/DeckCard.dart';
import 'package:benkyou/models/GrammarPointCard.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:flutter/material.dart';

class GrammarPointCardWidget extends StatelessWidget {
  final DeckCard card;
  final GrammarPointCard grammarCard;
  final Function onClick;

  const GrammarPointCardWidget(
      {Key key, @required this.card, @required this.grammarCard, this.onClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String exampleSentence = "";
    if (grammarCard.gapSentences != null &&
        grammarCard.gapSentences.isNotEmpty) {
      exampleSentence =
          grammarCard.gapSentences[0].replaceAll(new RegExp(r'{|}'), '');
    }
    String currentMeaning = (card.answers != null && card.answers.isNotEmpty
        ? card.answers[0].text
        : card.hint);
    return InkWell(
      onTap: onClick,
      child: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 5.0,
                  spreadRadius: 0.0,
                  offset: Offset(5.0, 5.0), // shadow direction: bottom right
                )
              ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      color: Color(COLOR_DARK_BLUE),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, top: 5, bottom: 5, right: 8),
                        child: Text(
                          "Grammar point: ${card.question}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      )),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Use case:",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text("${currentMeaning ?? ""}"),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Example:",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(exampleSentence),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
