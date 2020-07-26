import 'package:benkyou/models/User.dart';
import 'package:benkyou/services/api/userRequests.dart';
import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/CurvePainter.dart';
import 'package:benkyou/widgets/ExperienceBar.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  final bool isCurrentUserProfile;
  static const routeName = '/my-profile';

  const ProfilePage({Key key, this.userId, this.isCurrentUserProfile = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  Future<User> _user;

  Future<User> _fetchUser(int id) {
    if (widget.userId != null) {
      return getUserRequest(widget.userId);
    }
    return getMyProfileRequest();
  }

  @override
  void initState() {
    super.initState();
    _user = _fetchUser(widget.userId);
  }

  Widget _renderKeyNumberRow(User user) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 15),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Container(
                child: Center(
                    child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '57',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(LocalizationWidget.of(context)
                    .getLocalizeValue('likes')
                    .toUpperCase()),
              ],
            ))),
          ),
          Container(
            height: 30,
            child: VerticalDivider(
              thickness: 1.0,
              color: Colors.blueGrey,
            ),
          ),
          Expanded(
              child: Center(
                  child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '10 000',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(LocalizationWidget.of(context)
                  .getLocalizeValue('followers')
                  .toUpperCase()),
            ],
          ))),
          Container(
            height: 30,
            child: VerticalDivider(
              thickness: 1.0,
              color: Colors.blueGrey,
            ),
          ),
          Expanded(
              child: Center(
                  child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '579',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(LocalizationWidget.of(context)
                  .getLocalizeValue('following')
                  .toUpperCase()),
            ],
          ))),
        ],
      ),
    );
  }

  Widget _renderProfileHeader(Size phoneSize, User user) {
    return Container(
      height: phoneSize.height * 0.18,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Color(COLOR_DARK_BLUE),
              child: CustomPaint(
                painter: CurvePainter(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.lerp(
                Alignment.topCenter, Alignment.bottomCenter, 0.9),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Image(
                  image: AssetImage("lib/imgs/app_icon.png"),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _renderLessonsWidget(Size phoneSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          LocalizationWidget.of(context).getLocalizeValue('my_lessons'),
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        Container(
          height: phoneSize.width * 0.25 + 20,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 5.0, top: 10),
                  child: Container(
                    width: phoneSize.width * 0.25,
                    height: phoneSize.width * 0.25,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                  ),
                );
              }),
        ),
      ],
    );
  }

  Widget _renderExperienceResumeWidget(User user) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocalizationWidget.of(context).getLocalizeValue('experience'),
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                ExperienceBar(
                  skill: "Vocab",
                  percent: 0.20,
                ),
                ExperienceBar(
                  skill: "Grammar",
                  percent: 0.50,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var phoneSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title:
            Text(LocalizationWidget.of(context).getLocalizeValue('my_profile')),
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: _user,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                  child: Text(LocalizationWidget.of(context)
                      .getLocalizeValue('loading')));
            case ConnectionState.done:
              User user = snapshot.data;
              return Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _renderProfileHeader(phoneSize, user),
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: Text(
                                  user.username,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              _renderKeyNumberRow(user),
                              _renderLessonsWidget(phoneSize),
                              _renderExperienceResumeWidget(user)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            default:
              return Center(
                  child: Text(LocalizationWidget.of(context)
                      .getLocalizeValue('no_internet_connection')));
          }
        },
      ),
    );
  }
}
