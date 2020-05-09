import 'package:benkyou/models/Lesson.dart';
import 'package:benkyou/services/api/lessonRequests.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LessonPage extends StatefulWidget{
  static const routeName = '/lesson';
  final int lessonId;

  const LessonPage({Key key, @required this.lessonId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LessonPageState();

}

class LessonPageState extends State<LessonPage>{
  final controller = ScrollController();

  Future <Lesson> _lesson;

  void _fetchLessons(){
    _lesson = getLessonRequest(widget.lessonId);
  }

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson'),
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: _lesson,
        builder: (BuildContext context, AsyncSnapshot<Lesson> lessonSnapshot) {
          switch (lessonSnapshot.connectionState){
            case ConnectionState.waiting:
              return Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('loading')));
            case ConnectionState.done:
              return (SafeArea(
                child: Markdown(
                  controller: controller,
                  selectable: true,
                  data: lessonSnapshot.data.content,
                ),
              ));
            default:
              return Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('empty')));
          }
      },),
    );
  }
}