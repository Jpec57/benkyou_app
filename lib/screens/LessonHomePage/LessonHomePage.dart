import 'package:benkyou/models/Lesson.dart';
import 'package:benkyou/screens/LessonHomePage/LessonPage.dart';
import 'package:benkyou/screens/LessonHomePage/LessonPageArguments.dart';
import 'package:benkyou/services/api/lessonRequests.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LessonHomePage extends StatefulWidget{
  static const routeName = '/lessons';

  @override
  State<StatefulWidget> createState() => LessonHomePageState();

}

class LessonHomePageState extends State<LessonHomePage>{
  final controller = ScrollController();
  Future <List<Lesson>> _lessons;

  Future<List<Lesson>> _fetchLessons(){
    _lessons = getLessonsRequest();
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
        title: Text(LocalizationWidget.of(context).getLocalizeValue('lessons')),
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: _lessons,
        builder: (BuildContext context, AsyncSnapshot<List<Lesson>> lessonsSnapshot) {
          switch (lessonsSnapshot.connectionState){
            case ConnectionState.waiting:
              return Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('loading')));
            case ConnectionState.done:
              if (!lessonsSnapshot.hasData){
                return Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('error')));
              }
              List<Lesson> lessons = lessonsSnapshot.data;

              return (SafeArea(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lessons.length,
                  itemBuilder: (BuildContext context, int index) {
                    Lesson lesson = lessons[index];
                    return GestureDetector(
                      onTap: (){
                        Navigator.of(context).pushNamed(LessonPage.routeName, arguments: LessonPageArguments(lessonId: lesson.id));
                      },
                        child: ListTile(title: Center(child: Text("${lesson.title}", style: TextStyle(fontSize: 14),))));
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      color: Colors.grey,
                    );
                  },
                ),
              ));
            default:
              return Center(child: Text(LocalizationWidget.of(context).getLocalizeValue('empty')));
          }
        },),
    );
  }
}