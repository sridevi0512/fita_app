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
        body: Container(
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  this.widget.notify_message!,
                  maxLines: 5,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Color(0xff797979),
                    fontWeight: FontWeight.w500,
                    fontSize: 20
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Below are the meeting details: ",
                  maxLines: 2,
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xff797979),
                      fontWeight: FontWeight.w500,
                      fontSize: 20
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  this.widget.meet_link!,
                  maxLines: 2,
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xff797979),
                      fontWeight: FontWeight.w500,
                      fontSize: 20
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}
