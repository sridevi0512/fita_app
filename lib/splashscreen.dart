import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:first_app/homepage.dart';
import 'package:first_app/loginmainpage.dart';
import 'package:first_app/utils/constants.dart';
import 'package:first_app/utils/preference.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseMessaging _firebaseMessaging =   FirebaseMessaging.instance;
  var fcmToken;
  var currentFocus;
  bool _emailValidation= false;
  bool _mobileValidation= false;

  startTime() {
    var _duration =new Duration(seconds: 5);
    return new Timer(_duration,navigationPage);
  }

    getFirebaseToken()  {
        _firebaseMessaging.getToken().then((deviceToken) {
          assert(deviceToken != null);
          // if(this.mounted) {
            setState(() {
              print("Device Token: $deviceToken");
              fcmToken = deviceToken;
              Preference.setFirebaseToken(Constants.FIREBASE_TOKEN, fcmToken);
              print("token: $fcmToken");
              // showAlertDialog(context);
            });
          // }
        });
    }

  Future<void> navigationPage() async {
    print("Splash: Auth_Token ${(Preference.getAuthToken(
        Constants.AUTH_TOKEN))}");
    if(Preference.getAuthToken(Constants.AUTH_TOKEN) != null){
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("token", Preference.getAuthToken(Constants.AUTH_TOKEN));
    }

    print("Splash: User_id ${(Preference.getAuthToken(Constants.USER_ID))}");
    print("Splash: First_name ${(Preference.getFirstName(
        Constants.FIRST_NAME))}");
    print(
        "Splash: Last_name ${(Preference.getLastName(Constants.LAST_NAME))}");

    if (Preference.getAuthToken(Constants.AUTH_TOKEN) == "") {
      Navigator.pushReplacement(context,
          PageRouteBuilder(pageBuilder: (context, animation1, animation2) {
            return LoginMainPage();
          },
              transitionDuration: Duration(milliseconds: 1)));
    }

   /* else if(Preference.getFirstName(Constants.FIRST_NAME) == "") {
      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (context,animation1, animation2){
        return LoginMainPage();
      },transitionDuration: Duration(milliseconds: 1)));
    }

    else if(Preference.getLastName(Constants.LAST_NAME)== "") {
      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (context,animation1,animation2){
        return LoginMainPage();
      },transitionDuration: Duration(milliseconds: 1)));
    } */

    else if (Preference.getMobileVerified(Constants.MOBILE_VERIFIED) == false ||
        Preference.getMobileVerified(Constants.MOBILE_VERIFIED) == null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) {
            return LoginMainPage();
          },
          transitionDuration: Duration(milliseconds: 1),
        ),
      );
    } else if (Preference.getEmailVerified(Constants.EMAIL_VERIFIED) ==
        _emailValidation ||
        Preference.getEmailVerified(Constants.EMAIL_VERIFIED) == null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) {
            return LoginMainPage();
            //return CoursePaidPaymentScreen();
          },
          transitionDuration: Duration(milliseconds: 1),
        ),
      );
    }

    else{
      Navigator.pushReplacement(context,
          PageRouteBuilder(pageBuilder: (context,animation1, animation2){
        return HomePage(receiveCourseIdentity: 0);
      }, transitionDuration: Duration(milliseconds: 1) ));
    }
  }

  // showAlertDialog(BuildContext context){
  //   Widget okButton = TextButton(
  //       onPressed: (){Navigator.pop(context);},
  //       child: Text("OK"));

  //   AlertDialog alert = AlertDialog(
  //     title: Text("FCM Token"),
  //     content: Text(fcmToken),
  //     actions: [
  //       okButton,
  //     ],
  //   );

  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return alert;
  //       });
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    Preference.init();
    startTime();
    getFirebaseToken();
    allowPermit();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    if(kIsWeb){
      fcmToken.cancel();
    }

    super.dispose();
  }

  allowPermit() {
    if(Platform.isIOS){
      allowButton();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Stack(
        fit: StackFit.expand,
        children: [
          new Image.asset('images/splash_screen.jpg',fit: BoxFit.cover),

        ],
      ),
    );
  }
  Widget allowButton() {
    return OutlinedButton(
        child: Text("ALLOW MIC"),
        onPressed: () async {
          var status = await Permission.microphone.request().then((value) {
            print("After request()");
            return value;
          });
          print(status);
          var status1 = await Permission.photos.request().then((value) {
            print("After request1()");
            return value;
          });
          print(status1);


          if (await Permission.microphone.request().isGranted && await Permission.photos.request().isGranted) {
            print("OK!!!");
          } else {
            print("NOT OK!!!");
          }
        });
  }
}
