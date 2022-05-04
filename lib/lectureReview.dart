import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_app/main.dart';
import 'package:first_app/utils/apiUrl.dart';
import 'package:first_app/utils/connectivity.dart';
import 'package:first_app/utils/constants.dart';
import 'package:first_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class LectureReviewClass extends StatefulWidget {
   String lectureName,courseName,courseImage,notification_id;

  @override
  _LectureReviewClassState createState() => _LectureReviewClassState();
  LectureReviewClass({Key? key,
  required this.lectureName,
  required this.courseName,
  required this.courseImage,
  required this.notification_id}) :
        super(key: key);
}

class _LectureReviewClassState extends State<LectureReviewClass> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation? _animation;
  FocusNode _focusNode = FocusNode();
  var _formKey = GlobalKey<FormState>();
  TextEditingController concernController = new TextEditingController();
  bool readNot = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('notification_id init state' + this.widget.notification_id);
    _controller = AnimationController(vsync: this,duration: Duration(milliseconds: 300));
    _animation = Tween(begin: 300, end:50).animate(_controller!)
    ..addListener(() {
      setState(() {});
    });
    _focusNode.addListener(() {
      if(_focusNode.hasFocus) {
        _controller!.forward();
      } else {
        _controller!.reverse();
      }
    });
  }
  
  Future<String?> notificationConcernApi() async {
    showLoaderDialog(context);
    FocusScope.of(context).unfocus();
    final response = await http.post(
      Uri.parse(ApiUrl.BASE_COURSE_URL + ApiUrl.NOTIFICATION_CONCERN),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
      },
      body: jsonEncode({
        'notification_id': this.widget.notification_id,
        'readnotification' : readNot,
        "concernmessage" : concernController.text
      })
    );
    print('notification_id' + this.widget.notification_id);
    var jsonData = jsonDecode(response.body);
    try{
      if (response.statusCode == 200){
        Navigator.of(context,rootNavigator: true).pop('dialog');
        Navigator.pop(context);
        var data = jsonData['data'];
        print("lectureData ${data.toString()}");
        Fluttertoast.showToast(msg: jsonData['status']['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
        setState(() {});
      } else {
        print('Auth Token ${Preference.getAuthToken(Constants.AUTH_TOKEN)}');
        print(jsonData['status']['message']);
        Fluttertoast.showToast(msg: jsonData['status']['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
        Navigator.pop(context);
      }
    } catch(Exception) {
      Navigator.pop(context);
      print('Exception: ${Exception}');
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _controller!.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Write a Concern'),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "images/courses_bg.png"
              )
            )
          ),
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                Flexible(
            child:ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: CachedNetworkImage(
                      imageUrl: this.widget.courseImage,
                      fit: BoxFit.fill,
                      placeholder: (context,url) => Image.asset('images/no_image.png'),
                      errorWidget: (context,url,error) => Image.asset('images/no_image.png'),
                    ),
                  ),
                ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 25),
                child: Text(
                  this.widget.courseName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black
                  ),
                ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 25),
                child: Text(
                  this.widget.lectureName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:FontWeight.w500,
                    color: Colors.black
                  ),
                ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,top: 25),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: concernController,
                      maxLines: 5,
                      validator: (value) {
                        if(value!.length == 0 && value.length<10){
                          return 'Please raise your concern more than 10 characters';
                        } else {
                          return null;
                        }
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Raise your concern',
                        fillColor: Color.fromARGB(100, 230, 230, 230),
                        filled: true,
                        contentPadding: EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:BorderSide.none
                        ),
                        labelStyle: TextStyle(fontSize: 24, color: Colors.black)
                      ),
                      focusNode: _focusNode,
                    ),
                  ),
                ),
                RaisedButton(
                  padding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 30.0),
                  onPressed: () async {
                    if(_formKey.currentState!.validate()) {
                      var isNetwork = await ConnectivityState.connectivityState
                      .isNetworkAvailable();
                      if(isNetwork == true) {
                        notificationConcernApi();
                      } else {
                        ConnectivityState.showCustomDialog(
                            context,
                            title: 'Please make sure you are connected to internet and try again',
                        okBtnText: 'Okay'
                        );
                      }
                    } else {
                      print('null');
                    }
                    setState(() {});
                  },
                  color: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                  
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
