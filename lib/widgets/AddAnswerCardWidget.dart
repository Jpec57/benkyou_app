import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Localization.dart';

class AddAnswerCardWidget extends StatefulWidget {
  final String hint;
  final int cardId;
  final bool isScrollable;

  const AddAnswerCardWidget(
      {@required Key key, this.hint, this.cardId, this.isScrollable = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => AddAnswerCardWidgetState();
}

class AddAnswerCardWidgetState extends State<AddAnswerCardWidget> {
  DragStartDetails startHorizontalDragDetails;
  DragUpdateDetails updateHorizontalDragDetails;

  List<TextEditingController> textEditingControllers =
      <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    textEditingControllers.add(new TextEditingController());
  }

  void addAnswer({String value}) {
    textEditingControllers.add(new TextEditingController());
    if (value != null) {
      textEditingControllers[textEditingControllers.length - 1].text = value;
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (var controller in textEditingControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<String> getAnswerStrings() {
    List<String> answers = [];
    for (TextEditingController controller in textEditingControllers) {
      if (controller.text.isNotEmpty) {
        answers.add(controller.text);
      }
    }
    return answers;
  }

  void setNewAnswers(List<String> answers) {
    List<int> availableControllers = new List<int>();
    for (var i = 0; i < textEditingControllers.length; i++) {
      if (textEditingControllers[i].text.isEmpty) {
        availableControllers.add(i);
      }
    }
    int availableControllerNb = availableControllers.length;
    int answerNb = answers.length;
    int i = 0;
    while (i < availableControllerNb && i < answerNb) {
      textEditingControllers[availableControllers[i]].text = answers[i];
      i++;
    }
    while (i < answerNb) {
      addAnswer(value: answers[i]);
      i++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  LocalizationWidget.of(context)
                      .getLocalizeValue('possible_answers'),
                  style: TextStyle(fontSize: 20),
                ),
                GestureDetector(
                  child: Icon(Icons.add_circle),
                  onTap: () {
                    addAnswer();
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 50),
          child: ListView.builder(
              physics: widget.isScrollable
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              itemCount: textEditingControllers.length + 1,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (index == textEditingControllers.length) {
                  return (Container());
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: GestureDetector(
                    onHorizontalDragStart: (dragDetails) {
                      startHorizontalDragDetails = dragDetails;
                    },
                    onHorizontalDragUpdate: (dragDetails) {
                      updateHorizontalDragDetails = dragDetails;
                    },
                    onHorizontalDragEnd: (endDetails) {
                      double dx =
                          updateHorizontalDragDetails.globalPosition.dx -
                              startHorizontalDragDetails.globalPosition.dx;

                      double velocity = endDetails.primaryVelocity;

                      //Convert values to be positive
                      if (dx < 0) dx = -dx;

                      if (velocity > 0) {
                        textEditingControllers.removeAt(index);
                        setState(() {});
                      }
                    },
                    child: Card(
                      child: ListTile(
                        title: TextField(
                          controller: textEditingControllers[index],
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelStyle: TextStyle(fontSize: 20),
                            hintText: LocalizationWidget.of(context)
                                    .getLocalizeValue('possible_answer') +
                                ' ${index + 1}',
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
