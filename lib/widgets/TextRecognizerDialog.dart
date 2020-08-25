import 'dart:io';

import 'package:benkyou/utils/colors.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';

import 'Localization.dart';

class TextRecognizerDialog extends StatefulWidget {
  @override
  _TextRecognizerDialogState createState() => _TextRecognizerDialogState();
}

class _TextRecognizerDialogState extends State<TextRecognizerDialog> {
  List<String> _extractedLines = [];
  File _image;
  final cropKey = GlobalKey<CropState>();
  double _ratio = 4.0 / 3.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadImage(bool isFromGallery) async {
    ImagePicker imagePicker = ImagePicker();

    PickedFile pickedFile = await imagePicker.getImage(
        source: isFromGallery ? ImageSource.gallery : ImageSource.camera);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      setState(() {
        _image = file;
      });
    }
  }

  Future<void> extractText() async {
    if (_image != null) {
      final crop = cropKey.currentState;
      final scale = crop.scale;
      final area = crop.area;
      final sampledFile = await ImageCrop.sampleImage(
        file: _image,
        preferredWidth: (1024 / scale).round(),
        preferredHeight: (4096 / scale).round(),
      );

      final croppedFile = await ImageCrop.cropImage(
        file: sampledFile,
        area: area,
      );

      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFile(croppedFile);

      CloudTextRecognizerOptions options = CloudTextRecognizerOptions(
          hintedLanguages: ["ja"], textModelType: CloudTextModelType.dense);

      final TextRecognizer textRecognizer =
          FirebaseVision.instance.cloudTextRecognizer(options);
      final VisionText visionText =
          await textRecognizer.processImage(visionImage);

      _extractedLines = [];
      for (TextBlock block in visionText.blocks) {
        for (TextLine line in block.lines) {
          print(line.text);
          _extractedLines.add(line.text);
        }
      }
      textRecognizer.close();
      setState(() {});
    } else {
      Get.snackbar(
          'Error', "Please select an image from which you want to extract text",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  List<Widget> _renderListTiles() {
    List<Widget> widgets = [];
    for (int i = 0; i < _extractedLines.length; i++) {
      widgets.add(Dismissible(
        key: UniqueKey(),
        onDismissed: (direction) {
          _extractedLines.removeAt(i);
          setState(() {});
        },
        background: Container(color: Colors.red),
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(color: Color(COLOR_ANTRACITA))),
          child: ListTile(
            tileColor: Color(COLOR_LIGHT_GREY),
            shape: RoundedRectangleBorder(),
            title: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Text("${_extractedLines[i]}"),
            ),
          ),
        ),
      ));
    }
    return widgets;
  }

  Widget _renderReorderableListView() {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.3),
      child: ReorderableListView(
        padding: EdgeInsets.all(0),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            print("oldIndex $oldIndex newIndex $newIndex");
            if (oldIndex == 0) {
              newIndex--;
            }
            if (newIndex >= _extractedLines.length) {
              newIndex--;
            }
            String tmpStr = _extractedLines[oldIndex];
            _extractedLines[oldIndex] = _extractedLines[newIndex];
            _extractedLines[newIndex] = tmpStr;
            setState(() {});
          });
        },
        children: _renderListTiles(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String _extractedText = _extractedLines.join(' ');
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.all(10.0),
      title:
          Text(LocalizationWidget.of(context).getLocalizeValue('extract_text')),
      content: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      "(1/3) ${LocalizationWidget.of(context).getLocalizeValue('choose_picture')}",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontSize: 18),
                    ),
                  ),
                  Container(
                    color: Color(COLOR_ANTRACITA),
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: _image != null
                        ?
                        //Image(fit: BoxFit.contain, image: FileImage(_image))
                        Crop(
                            key: cropKey,
                            image: FileImage(_image),
                            aspectRatio: _ratio,
                          )
                        : Center(
                            child: Text(
                            LocalizationWidget.of(context)
                                .getLocalizeValue('no_photo'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          )),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await loadImage(false);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Color(COLOR_DARK_BLUE),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10))),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                  child: Text(
                                LocalizationWidget.of(context)
                                    .getLocalizeValue('take_photo'),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              )),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await loadImage(true);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Color(COLOR_ORANGE),
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10))),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                  child: Text(
                                LocalizationWidget.of(context)
                                    .getLocalizeValue('take_gallery'),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              )),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: _image != null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Slider(
                          value: _ratio,
                          min: 1,
                          max: 5,
                          onChanged: (double value) {
                            setState(() {
                              _ratio = value;
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: RaisedButton(
                            onPressed: () async {
                              await extractText();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            color: Color(COLOR_ORANGE),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Center(
                                  child: Text(
                                LocalizationWidget.of(context)
                                    .getLocalizeValue('extract')
                                    .toUpperCase(),
                                style: Theme.of(context).textTheme.headline3,
                              )),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  "(2/3) ${LocalizationWidget.of(context).getLocalizeValue('organize_extracted_text')}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(fontSize: 18),
                                ),
                              ),
                              _extractedLines.length > 0
                                  ? Container(
                                      child: _renderReorderableListView())
                                  : Padding(
                                      padding: const EdgeInsets.all(5),
                                      //_extractedLines
                                      child: Center(
                                        child: Text(
                                          LocalizationWidget.of(context)
                                              .getLocalizeValue(
                                                  'no_extracted_text'),
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    ),
                              Visibility(
                                visible: _extractedLines.length > 0,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15, bottom: 8),
                                      child: Text(
                                        "(3/3) ${LocalizationWidget.of(context).getLocalizeValue('result')}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(fontSize: 18),
                                      ),
                                    ),
                                    Text(
                                      _extractedText,
                                      textAlign: TextAlign.center,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: RaisedButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        color: Color(COLOR_DARK_BLUE),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(_extractedText);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            LocalizationWidget.of(context)
                                                .getLocalizeValue(
                                                    'extract_sentence')
                                                .toUpperCase(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
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
