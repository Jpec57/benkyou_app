import 'package:benkyou/utils/colors.dart';
import 'package:benkyou/widgets/MainDrawer.dart';
import 'package:flutter/material.dart';

class SectionContainer extends StatelessWidget {
  final Color color;
  final Widget child;

  const SectionContainer({Key key, @required this.color, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            color: color,
            child: child,
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _renderBigIcon(IconData icon) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Icon(icon, color: Colors.white, size: constraints.biggest.height),
        );
      },
    );
  }

  Widget _renderVocabSection() {
    return GestureDetector(
      onTap: () {},
      child: _renderBigIcon(Icons.add_circle),
    );
  }

  Widget _rendeGrammarSection() {
    return GestureDetector(
      onTap: () {},
      child: _renderBigIcon(Icons.add_circle),
    );
  }

  Widget _renderLessonSection() {
    return GestureDetector(
      onTap: () {},
      child: _renderBigIcon(Icons.add_circle),
    );
  }

  Widget _renderThemeSection() {
    return GestureDetector(
      onTap: () {},
      child: _renderBigIcon(Icons.add_circle),
    );
  }

  Widget _renderAllSection() {
    return GestureDetector(
      onTap: () {},
      child: _renderBigIcon(Icons.add_circle),
    );
  }

  Widget _renderDrawSection() {
    return GestureDetector(
      onTap: () {},
      child: _renderBigIcon(Icons.add_circle),
    );
  }

  Widget _renderSection(Widget sectionWidget, {String text = "Grammar"}) {
    return SectionContainer(
      color: Color(COLOR_ORANGE),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: sectionWidget),
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0, top: 8),
              child: Text(
                text,
                style: Theme.of(context).textTheme.headline5,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: MainDrawer(),
      body: Container(
        color: Color(COLOR_ANTRACITA),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: 20, bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    color: Color(COLOR_ORANGE),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 15, bottom: 20, left: 25, right: 25),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Text(
                              "Daily kanji",
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height *
                                          0.25),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 30, right: 30, top: 15, bottom: 15),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black45, width: 3),
                                      borderRadius: BorderRadius.circular(25)),
                                  child: LayoutBuilder(
                                    builder: (BuildContext context,
                                        BoxConstraints constraints) {
                                      return Center(
                                        child: Text(
                                          "力",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  constraints.biggest.height /
                                                      2),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 35, right: 35, bottom: 10),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _renderSection(_renderDrawSection()),
                          _renderSection(_renderDrawSection()),
                          _renderSection(_renderDrawSection()),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _renderSection(_renderDrawSection()),
                          _renderSection(_renderDrawSection()),
                          _renderSection(_renderDrawSection()),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
//            Expanded(
//              flex: 3,
//              child: Padding(
//                padding: const EdgeInsets.only(
//                    top: 10, left: 35, right: 35, bottom: 10),
//                child: GridView.count(
//                    shrinkWrap: true,
//                    physics: NeverScrollableScrollPhysics(),
//                    mainAxisSpacing: 20,
//                    crossAxisSpacing: 20,
//                    childAspectRatio: 1,
//                    crossAxisCount: 3,
//                    key: ValueKey('section-grid'),
//                    children: List.generate(6, (index) {
//                      return _renderSection();
//                    })),
//              ),
//            ),
          ],
        ),
      ),
    );
  }
}
