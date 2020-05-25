import 'package:benkyou/models/DialogText.dart';
import 'package:benkyou/models/UserDialog.dart';
import 'package:benkyou/screens/DialogPage/InDialogPage.dart';
import 'package:benkyou/screens/DialogPage/InDialogPageArguments.dart';
import 'package:benkyou/services/api/dialogRequests.dart';
import 'package:benkyou/widgets/Localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListDialogPage extends StatefulWidget {
  static const routeName = '/dialogs';
  @override
  State<StatefulWidget> createState() => ListDialogPageState();
}

class ListDialogPageState extends State<ListDialogPage>{
  Future<List<UserDialog>> _dialogs;

  @override
  void initState() {
    super.initState();
    _dialogs = getDialogsRequest();
  }

  ImageProvider _renderDialogThumbnail(UserDialog dialog){
    DialogText firstDialog = dialog.firstDialog;
    if (firstDialog.backgroundImg != null && firstDialog.backgroundImg.isNotEmpty){
      return NetworkImage(firstDialog.backgroundImg);
    }
    return AssetImage("lib/imgs/japan.png");
  }

  Widget _renderDialogTile(UserDialog dialog){
    return GestureDetector(
        onTap: (){
          Navigator.of(context).pushNamed(InDialogPage.routeName, arguments: InDialogPageArguments(dialogId: dialog.id));
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 2.0,
                spreadRadius: 0.0,
                offset: Offset(
                    2.0, 2.0), // shadow direction: bottom right
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
                              image: _renderDialogThumbnail(dialog),
                              fit: BoxFit.cover)
                      ),
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
                              "${dialog.title}"
                              , style: TextStyle(fontSize: 18),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "${dialog.author != null ? dialog.author.username : 'Jpec'}"
                                , style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "${dialog.description}"
                                , style: TextStyle(fontSize: 14),
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
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationWidget.of(context).getLocalizeValue('list_dialogs')),
      ),
      body: FutureBuilder(
          future: _dialogs,
          builder: (BuildContext context, AsyncSnapshot<List<UserDialog>> snapshot) {
            switch (snapshot.connectionState){
              case ConnectionState.done:
                List<UserDialog> dialogs = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: dialogs.length,
                    itemBuilder: (BuildContext context, int index) {
                      UserDialog dialog = dialogs[index];
                      return _renderDialogTile(dialog);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        color: Colors.grey,
                      );
                    },
                  ),
                );
              case ConnectionState.waiting:
                return Center(
                  child: Text(LocalizationWidget.of(context).getLocalizeValue('loading')),
                );
              default:
                return Center(
                  child: Text(LocalizationWidget.of(context).getLocalizeValue('generic_error')),
                );
            }
          },
      ),
    );
  }
}