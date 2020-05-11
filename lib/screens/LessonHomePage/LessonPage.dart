import 'package:benkyou/models/Lesson.dart';
import 'package:benkyou/services/api/lessonRequests.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonPage extends StatefulWidget {
  static const routeName = '/lesson';
  final int lessonId;

  const LessonPage({Key key, @required this.lessonId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LessonPageState();
}

class LessonPageState extends State<LessonPage> {
  final controller = ScrollController();
  YoutubePlayerController _videoPlayerController;

  Future<Lesson> _lesson;

  void _fetchLessons() {
    _lesson = getLessonRequest(widget.lessonId);
  }

  @override
  void initState() {
    super.initState();
    _fetchLessons();
    _initVideo();
  }

  void _initVideo() async {
    Lesson lesson = await _lesson;
    if (lesson.videoUrl != null && lesson.videoUrl.isNotEmpty) {
      String videoId = YoutubePlayer.convertUrlToId(lesson.videoUrl);
      _videoPlayerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }

  Widget _renderCoverImage(Lesson lesson){
    if (lesson.banniere != null && lesson.banniere.isNotEmpty){
      return Container(
        height: MediaQuery.of(context).size.height * 0.3,

        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(lesson.banniere),
                fit: BoxFit.cover)
        ),
      );
    }
    return Container();
  }

  Widget _renderVideo(Lesson lesson) {
    if (lesson.videoUrl != null && lesson.videoUrl.isNotEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.3,
        child: YoutubePlayer(
          controller: _videoPlayerController,
          showVideoProgressIndicator: true,
        ),
      );
    }
    return _renderCoverImage(lesson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson'),
      ),
      body: FutureBuilder(
        future: _lesson,
        builder: (BuildContext context, AsyncSnapshot<Lesson> lessonSnapshot) {
          switch (lessonSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                  child: Text(LocalizationWidget.of(context)
                      .getLocalizeValue('loading')));
            case ConnectionState.done:
              return (SafeArea(
                child: Column(
                  children: [
                    _renderVideo(lessonSnapshot.data),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Markdown(
                          controller: controller,
                          selectable: true,
                          data: lessonSnapshot.data.content,
                        ),
                      ),
                    ),
                  ],
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