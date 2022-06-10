import 'package:flutter/material.dart';
class NotificationClickedPage extends StatefulWidget {
  String? meet_link, notify_message;
   NotificationClickedPage({Key? key,
   this.meet_link,
   this.notify_message}) : super(key: key);

  @override
  State<NotificationClickedPage> createState() => _NotificationClickedPageState();
}

class _NotificationClickedPageState extends State<NotificationClickedPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        
      ),
    );
  }
}
