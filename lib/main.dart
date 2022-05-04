import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:first_app/loginmainpage.dart';
import 'package:first_app/otppage.dart';
import 'package:first_app/registerscreen.dart';
import 'package:first_app/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:first_app/pushNotification.dart';
var localStore;

showLoaderDialog(BuildContext context){
  AlertDialog alert =AlertDialog(
    content: new Row(
      children: [
        CircularProgressIndicator(),
        Container(margin: EdgeInsets.only(left: 7),child: Text("Loading.....")),
      ],
    ),
  );
  showDialog(barrierDismissible:false,context: context, builder: (BuildContext context){
    return alert;
  });
}
Future<void> main()  async {
  WidgetsFlutterBinding.ensureInitialized();
   // await Firebase.initializeApp();

  (Platform.isAndroid)?
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyCY1f4u3bOur9U4ERWBCkD5ZCk7bst0qF0" /*"AIzaSyATR5b0Hu-a8y64CdV30BdIb_HB3Cwz2I0"*/,
        projectId: "fita-340610",
        messagingSenderId: "934356910219",
        appId: "1:934356910219:android:3b6560b627a9bde643148e"),
  ):
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey:  "AIzaSyATR5b0Hu-a8y64CdV30BdIb_HB3Cwz2I0",
        projectId: "fita-340610",
        messagingSenderId: "934356910219",
        appId: "1:934356910219:android:3b6560b627a9bde643148e"),
  );

  try{
    if(Platform.isAndroid || Platform.isIOS){
      await FlutterDownloader.initialize(
          debug: true
      );

    }
  }catch(Exception){

  }


  runApp(MyApp());



}



class MyApp extends StatelessWidget {
  // const MyApp({Key? key}) : super(key: key);
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  @override
  Widget build(BuildContext context) {
    final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();
    return MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Montserrat',
          backgroundColor:Colors.white
      ),
      routes: <String,WidgetBuilder>{
        '/mobile_screen':(context)=> LoginMainPage(),
        /*'/register' : (context) => RegisterScreen(),
        '/verification' : (context) => VerificationScreen(),
        '/otpscreen' : (context) => OtpPage(),
        '/assessment_non_degree': (context) => AssessmentNonDegree(),
        '/assessment_launch': (context) => AssessmentLaunch(),
        '/assessment_course': (context) => AssessmentCourse()*/

      },
      home: const SplashScreen(),

    );

  }

}







 



