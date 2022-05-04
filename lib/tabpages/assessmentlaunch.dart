import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:first_app/loginmainpage.dart';
import 'package:first_app/main.dart';
import 'package:first_app/utils/apiUrl.dart';
import 'package:first_app/utils/constants.dart';
import 'package:first_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../assessment.dart';
import 'course.dart';

class AssessmentLaunch extends StatefulWidget {
  String token;

  @override
  _AssessmentLaunchState createState() => _AssessmentLaunchState();
  AssessmentLaunch({Key? key, required this.token}) : super(key: key);
}

class _AssessmentLaunchState extends State<AssessmentLaunch> {
  int checkingvalue = 4;
  String? courseIdentity;
  bool? isLogged;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("user_token: ${Preference.getAuthToken(Constants.AUTH_TOKEN)}");
    if(Preference.getAuthToken(Constants.AUTH_TOKEN) != "") {
      isLogged = false;
    }else {
      isLogged = true;
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      var data = message.notification;
      print("Notifications: $data");
      setState(() {});
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpened App");
      /*Navigator.pushNamed(context, '/message',
      arguments: MessageArguments(message,true));
      */
      setState(() {});

    });
  }

  Future<String?> logoutApi() async {
    showLoaderDialog(context);
    var response;
    response = await http.post(Uri.parse(ApiUrl.BASE_URL + ApiUrl.LOGOUT),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": Preference.getAuthToken(Constants.AUTH_TOKEN)
      },
    );
    try{
      Navigator.pop(context);
      var data = json.decode(response.body);
      print('Logout Try');
      Fluttertoast.showToast(msg: data['session']['token'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      if(response == 200){
        print('Logout 200');
        print('if');
      }else if(response == 400){
        print('Logout 400');
        var data1 = json.decode(response.body);
        Fluttertoast.showToast(msg: data1['status']['message'],toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.BOTTOM);
        print("data1:"+ data1['status']['message']);
      }
      if(data['status']['status'] == "Success") {
        Navigator.pushReplacement(context,
            PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) {
                  return LoginMainPage();
                },
                transitionsBuilder: (context,animation1, animation2, child) {
                  return FadeTransition(
                    opacity: animation1,
                    child: child,
                  );
                },
                transitionDuration: Duration(milliseconds: 1))
        );
        Preference.setAuthToken(Constants.AUTH_TOKEN, "");
        Fluttertoast.showToast(msg: data['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      } else {
        Navigator.pushReplacement(context,
            PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) {
                  return LoginMainPage();
                },
                transitionsBuilder: (context, animation1, animation2, child){
                  return FadeTransition(
                    opacity: animation1,
                    child: child,
                  );
                },
                transitionDuration: Duration(milliseconds: 1)
            ));
        Preference.setAuthToken(Constants.AUTH_TOKEN, "");
        Fluttertoast.showToast(msg: "Logged out successfully",toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);

      }

    } catch (Exception) {
      print('Logout Catch');
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "The server is temporarily unable to service your request",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }
  @override
  Widget build(BuildContext context) {
    /*WillPopScope(*/
    // onWillPop: () {  },
    return SafeArea(
      child: Scaffold(

        body: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              image: DecorationImage(
                image:ExactAssetImage('images/courses_bg.png'),
                fit: BoxFit.cover,
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  checkingvalue = 1;
                  print("firstTapped");
                  setState(() {});
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Assessment(token: this.widget.token))
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(40.0, 5.0, 40.0, 5.0),
                      ),
                      Container(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: "Take Quick Assessment",
                            fillColor: Color.fromARGB(255, 14, 123, 215),
                            filled: true,
                            enabled: false,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(75.0),
                                borderSide: BorderSide.none
                            ),
                            hintStyle: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black38,
                                blurRadius: 25,
                                offset: const Offset(0, 5)
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005,
                      ),
                      Container(
                          margin: EdgeInsets.all(10.0),
                          child: Text("Find your Goal in less than 3 Minutes",
                            maxLines: 2,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          )
                      ),

                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  checkingvalue = 1;
                  localStore = 'explourePaidCourse';
                  courseIdentity = 'paid course';
                  localStore = courseIdentity;
                  print("Secondtapped");
                  setState(() {});
                  /*Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Assessment()));*/
                  /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => homeMainScreen(
                                  receivecCourseIdentity: 1,
                                )));*/
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Course()));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(40.0, 5.0, 40.0, 5.0), //
                      ),
                      Container(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Explore Courses',
                            //fillColor: Colors.blueAccent,
                            fillColor: Color.fromARGB(255, 14, 123, 215),
                            filled: true,
                            enabled: false,
                            //contentPadding: EdgeInsets.all(10.0),
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(75.0)),
                                borderSide: BorderSide.none),
                            hintStyle: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 25,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005),
                      Container(
                        //width: MediaQuery.of(context).size.width * 0.35,
                        margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        child: Text("I am Clear with My Goal",
                            maxLines: 2,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
                //),
              ),
              GestureDetector(
                onTap: () {
                  localStore = 'exploureFreeCourse';
                  courseIdentity = 'free course';
                  checkingvalue = 1;
                  print("Thirdtapped");
                  setState(() {});
                  /*Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Assessment()));*/
                  /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => homeMainScreen(
                                  receivecCourseIdentity: 1,
                                )));*/
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Course()));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(40.0, 5.0, 40.0, 5.0), //
                      ),
                      Container(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Explore Free Courses',
                            //fillColor: Colors.blueAccent,
                            fillColor: Color.fromARGB(255, 14, 123, 215),
                            filled: true,
                            enabled: false,
                            //contentPadding: EdgeInsets.all(10.0),
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(75.0)),
                                borderSide: BorderSide.none),
                            hintStyle: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                            /*labelStyle: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)*/
                          ),
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 25,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.035),
                    ],
                  ),
                ),

                //),
              ),
              /* GestureDetector(
                  onTap: () {
                    localStore = 'concern_status';
                    courseIdentity = 'concern_status';
                    checkingvalue = 1;
                    //print("Thirdtapped");
                    setState(() {});
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConcernStatusClass()));
                    */ /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => homeMainScreen(
                                  receivecCourseIdentity: 1,
                                )));*/ /*
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(40.0, 5.0, 40.0, 5.0), //
                        ),
                        Container(
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Concern Status',
                              //fillColor: Colors.blueAccent,
                              fillColor: Color.fromARGB(255, 14, 123, 215),
                              filled: true,
                              enabled: false,
                              //contentPadding: EdgeInsets.all(10.0),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(75.0)),
                                  borderSide: BorderSide.none),
                              hintStyle: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                              */ /*labelStyle: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)*/ /*
                            ),
                          ),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 25,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.035),
                      ],
                    ),
                  ),

                  //),
                ),
                GestureDetector(
                  onTap: () {
                    localStore = 'raise_concern';
                    courseIdentity = 'raise_concern';
                    checkingvalue = 1;
                    //print("Thirdtapped");
                    setState(() {});
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RaiseConcernClass()));
                    */ /*Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Assessment()));*/ /*
                    */ /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => homeMainScreen(
                                  receivecCourseIdentity: 1,
                                )));*/ /*
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(40.0, 5.0, 40.0, 5.0), //
                        ),
                        Container(
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Raise a Concern',
                              //fillColor: Colors.blueAccent,
                              fillColor: Color.fromARGB(255, 14, 123, 215),
                              filled: true,
                              enabled: false,
                              //contentPadding: EdgeInsets.all(10.0),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(75.0)),
                                  borderSide: BorderSide.none),
                              hintStyle: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                              */ /*labelStyle: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)*/ /*
                            ),
                          ),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 25,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.075),
                      ],
                    ),
                  ),

                  //),
                ),*/
            ],
          ),
        ),
      ),

    );
  }
}
