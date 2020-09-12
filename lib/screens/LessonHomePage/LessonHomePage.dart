import 'package:benkyou/models/Lesson.dart';
import 'package:benkyou/screens/LessonHomePage/LessonPage.dart';
import 'package:benkyou/screens/LessonHomePage/LessonPageArguments.dart';
import 'package:benkyou/services/api/lessonRequests.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonHomePage extends StatefulWidget {
  static const routeName = '/lessons';

  @override
  State<StatefulWidget> createState() => LessonHomePageState();
}

class LessonHomePageState extends State<LessonHomePage> {
  final controller = ScrollController();
  Future<List<Lesson>> _lessons;

  Future<List<Lesson>> _fetchLessons() {
    _lessons = getLessonsRequest();
  }

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  ImageProvider _renderLessonThumbnail(Lesson lesson) {
    if (lesson.banniere != null && lesson.banniere.isNotEmpty) {
      return NetworkImage(lesson.banniere);
    }
    if (lesson.videoUrl != null && lesson.videoUrl.isNotEmpty) {
      String videoId = YoutubePlayer.convertUrlToId(lesson.videoUrl);
      String quality = ThumbnailQuality.standard;
      return NetworkImage('https://i3.ytimg.com/vi_webp/$videoId/$quality');
    }
    return AssetImage("lib/imgs/japan.png");
  }

  /// Grabs YouTube video's thumbnail for provided video id.
  static String getThumbnail({
    @required String videoId,
    String quality = ThumbnailQuality.standard,
  }) =>
      'https://i3.ytimg.com/vi_webp/$videoId/$quality';

  Widget _renderLessonTile(Lesson lesson) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(LessonPage.routeName,
              arguments: LessonPageArguments(lessonId: lesson.id));
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 2.0,
                spreadRadius: 0.0,
                offset: Offset(2.0, 2.0), // shadow direction: bottom right
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: _renderLessonThumbnail(lesson),
                              fit: BoxFit.cover)),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${lesson.title}",
                              style: TextStyle(fontSize: 18),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "${lesson.author != null ? lesson.author.username : 'Jpec'}",
                                style: TextStyle(
                                    fontSize: 14, fontStyle: FontStyle.italic),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "${lesson.description}",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
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
        builder: (BuildContext context,
            AsyncSnapshot<List<Lesson>> lessonsSnapshot) {
          switch (lessonsSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                  child: Text(LocalizationWidget.of(context)
                      .getLocalizeValue('loading')));
            case ConnectionState.done:
              if (!lessonsSnapshot.hasData) {
                return Center(
                    child: Text(LocalizationWidget.of(context)
                        .getLocalizeValue('empty')));
              }
              List<Lesson> lessons = lessonsSnapshot.data;

              return (SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: lessons.length,
                    itemBuilder: (BuildContext context, int index) {
                      Lesson lesson = lessons[index];
                      return _renderLessonTile(lesson);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ));
            default:
              return Center(
                  child: Text(LocalizationWidget.of(context)
                      .getLocalizeValue('empty')));
          }
        },
      ),
    );
  }
}
