import 'package:flutter/material.dart';

class MyCourse extends StatefulWidget {
  const MyCourse({Key? key}) : super(key: key);

  @override
  _MyCourseState createState() => _MyCourseState();
}

class _MyCourseState extends State<MyCourse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Course'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Text(
            "My Course Screen"
        ),
      ),

    );
  }
}
