import 'package:flutter/material.dart';

import 'TextRecognizerDialog.dart';

typedef void StringCallback(String str);

class TextRecognizerIcon extends StatefulWidget {
  final StringCallback callback;
  final double size;
  final Color color;

  const TextRecognizerIcon({Key key, this.callback, this.size = 18, this.color})
      : super(key: key);

  @override
  _TextRecognizerIconState createState() => _TextRecognizerIconState();
}

class _TextRecognizerIconState extends State<TextRecognizerIcon> {
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
    return GestureDetector(
      onTap: () async {
        await showDialog(
                context: context,
                builder: (BuildContext context) => TextRecognizerDialog())
            .then((string) {
          widget.callback(string);
        });
      },
      child: Icon(
        Icons.photo_camera,
        size: widget.size,
        color: widget.color,
      ),
    );
  }
}
