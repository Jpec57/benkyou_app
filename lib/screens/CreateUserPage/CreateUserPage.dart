import 'package:benkyou_app/widgets/MainDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateUserPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => CreateUserPageState();

}

class CreateUserPageState extends State<CreateUserPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Create account'),
      ),
      body: Container(
        child: Center(
          child: Text("HERE"),
        ),
      ),
    );
  }

}