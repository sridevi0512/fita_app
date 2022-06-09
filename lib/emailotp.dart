import 'dart:async';
import 'dart:convert';
import 'package:fita_app/homepage.dart';
import 'package:fita_app/main.dart';
import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/connectivity.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
// import 'package:pin_entry_text_field/pin_entry_text_field.dart';

class EmailOTP extends StatefulWidget {
  const EmailOTP({Key? key}) : super(key: key);

  @override
  _EmailOTPState createState() => _EmailOTPState();
}

class _EmailOTPState extends State<EmailOTP> {
  late double unitHeightValue;
  var _formKey = GlobalKey<FormState>();
  bool _resendOtp = false;
  String otp ='';
  Timer? _timer;
  final interval = const Duration(seconds: 1);
  final int timerMaxSeconds = 180;
  int currentSeconds = 0;
  int screenCount = 0;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2,'0')} : ${((timerMaxSeconds - currentSeconds) %60).toString().padLeft(2,'0')}';
  
  startTimerout([int? milliSeconds]) {
    var duration = interval;
    _timer = new Timer.periodic(duration, (timer) { 
      setState(() {
        // print(timer.tick);
        currentSeconds = timer.tick;
        if(timer.tick >= timerMaxSeconds) {
          timer.cancel();
          
        }
        
      });
    });
    
  }
  
  @override
  void dispose() {
    // TODO: implement dispose
    _timer!.cancel();
    super.dispose();
    
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimerout();
    
  }
  
  Future<String?> profileUpdateApi() async {
    final response = await http.post(Uri.parse(ApiUrl.BASE_URL + ApiUrl.PROFILE_UPDATE),
    headers: <String,String> {
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization': Preference.getAuthToken(Constants.AUTH_TOKEN)
    },
    body: jsonEncode({
      'user_id': Preference.getUserId(Constants.USER_ID),
      'email': Preference.getEmail(Constants.EMAIL),
      'first_name': Preference.getFirstName(Constants.FIRST_NAME),
      'last_name' : Preference.getLastName(Constants.LAST_NAME)
    }));
    try {
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print("profile_update" + jsonData.toString());
        Preference.setEmailVerified(Constants.EMAIL_VERIFIED, true);
        Navigator.of(context).popUntil((_) => screenCount++ >= 4);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(
                      receiveCourseIdentity: 0,
                    )));
        Fluttertoast.showToast(
            msg: jsonData['status']['message'], toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM);
        print(jsonData['status']['message']);
      } else {
        FocusScope.of(context).requestFocus(new FocusNode());
        Navigator.pop(context);
        var data = json.decode(response.body);
        Fluttertoast.showToast(msg: data['status']['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM);
      }
    } catch (Exception) {
      print('Exception');
    }
  }
  
  Future<String?> emailOTPVerification() async {
    showLoaderDialog(context);
    var response;
    if(_resendOtp) {
      print('resend');
      response = await http.post(Uri.parse(ApiUrl.BASE_URL + ApiUrl.EMAIL_RESEND),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': Preference.getAuthToken(Constants.AUTH_TOKEN)
      },
        body: jsonEncode(<String, String> {
          'user_id' : Preference.getUserId(Constants.USER_ID),
          'email' : Preference.getEmail(Constants.EMAIL)
        })
      );
      try {
        Navigator.pop(context);
        var data = json.decode(response.body);
        if(response.statusCode == 200) {
          FocusScope.of(context).requestFocus(new FocusNode());
          print("EMAIL if:" + data['status']['message']);
          Fluttertoast.showToast(msg: data['status']['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM);
        } else {
          FocusScope.of(context).requestFocus(new FocusNode());
          print("EMAIL else:" + data['status']['message']);
          Fluttertoast.showToast(msg: data['status']['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM);
        }
      }catch(Exception) {
        print('EMAIL Excep: ');
        FocusScope.of(context).requestFocus(new FocusNode());
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'The server is temporarily unable to service your request',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM);
      }
    }else{
      response = await http.post(Uri.parse(ApiUrl.BASE_URL + ApiUrl.EMAIL_VERIFY),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': Preference.getAuthToken(Constants.AUTH_TOKEN)
      },
        body: jsonEncode(<String, String>{
          'email_otp' : otp,
          'user_id' : Preference.getUserId(Constants.USER_ID)
        })
      );
      try{
        Navigator.pop(context);
        var data = json.decode(response.body);
        print(data);
        if(response.statusCode == 200) {
          profileUpdateApi();
          print('verify email');
          _timer!.cancel();
          if(data['status']['status'] == "Success") {
            print('Verify Email data: ' + data.toString());
            _resendOtp = true;
            _formKey.currentState!.reset();
            Preference.setEmail(Constants.EMAIL, data['data']['email']);
            print(
              'profile user_id' + Preference.getUserId(Constants.USER_ID));
            print('profile_email ' + Preference.getEmail(Constants.EMAIL));
            print('profile first_name:' + Preference.getFirstName(Constants.FIRST_NAME));
            print('profile last_name:' + Preference.getLastName(Constants.LAST_NAME));
            if(data['data']['email_verified'] == true) {
              print('email_verified');
            } else if (data['data']['mobile_verified'] == false) {
              _resendOtp = true;
              print('mobile verified');
              Fluttertoast.showToast(msg: "mobile not verified",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM);
            } else{
              print('home screen');
            }
            Fluttertoast.showToast(msg: data['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
          }else{
            FocusScope.of(context).requestFocus(new FocusNode());
            _formKey.currentState!.reset();
            print(data["status"]['message']);
            Fluttertoast.showToast(msg: data['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);

          }
        } else {
          _timer!.cancel();
          FocusScope.of(context).requestFocus(new FocusNode());
          _formKey.currentState!.reset();
          Fluttertoast.showToast(msg: data['status']['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
        }
      }catch (Exception) {
        _timer!.cancel();
        FocusScope.of(context).requestFocus(FocusNode());
        Fluttertoast.showToast(msg: 'The server is temporarily unable to service your request',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
      }

    }
  }


  @override
  Widget build(BuildContext context) {
    unitHeightValue = MediaQuery.of(context).size.height * 0.001;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.10,
          elevation: 15,
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 249, 249, 249),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context,
              PageRouteBuilder(
                  pageBuilder: (context,animation1, animation2) {
                    return SizedBox();
                  },
              transitionsBuilder: (context,animation1,animation2, child){
                    return FadeTransition(opacity: animation1,
                    child: child);
              },
              transitionDuration: Duration(milliseconds: 2000),
              ));
            },
            icon: Icon(Icons.arrow_back_ios),
            iconSize: 25,
            color: Colors.black,
          ),
          title: Text(
            "Verification",
            style: TextStyle(color: Colors.black,fontSize: 24 * unitHeightValue),

          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(0.0),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/courses_bg.png'),
                fit: BoxFit.cover
              )
            ),
            child: new Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Verify Your Email",
                    style: TextStyle(
                      wordSpacing: 1,
                      color: Colors.black,
                      fontSize: 35 * unitHeightValue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,

                  ),
                  Text(
                    'Enter your OTP code here',
                    style: TextStyle(
                      fontSize: 20 * unitHeightValue,
                      color: Colors.grey[600]
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.020,
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                  child: SizedBox(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 20.0, horizontal:15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PinEntryTextField(
                            onSubmit: (String pin) {
                              if(pin.length == 4){
                                otp = pin;
                                emailOTPVerification();
                              }
                              print("Submit OTP: $otp");
                            }),
                        ],
                      ),
                    ),
                  ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            text: "Didn't receive the code? ",
                            style: TextStyle(
                                fontSize: 19 * unitHeightValue,
                                color: Colors.grey[600],
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                              text: "Click here...",
                              style: TextStyle(
                                  fontSize: 19 * unitHeightValue,
                                  color:
                                  _resendOtp ? Colors.blue : Colors.grey[600],
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.normal),
                              recognizer: new TapGestureRecognizer()
                                ..onTap = () async {
                                  var isNetwork = await ConnectivityState
                                      .connectivityState
                                      .isNetworkAvailable();
                                  print('resend otp clicked');
                                  if (isNetwork == true) {
                                    if (_resendOtp) {
                                      emailOTPVerification();
                                    }
                                  } else {
                                    ConnectivityState.showCustomDialog(
                                      context,
                                      title:
                                      'Please make sure you are connected to internet and try again',
                                      okBtnText: 'Okay',
                                    );
                                  }
                                  print('ssss');
                                }),
                          TextSpan(
                            text: "\n$timerText",
                            style: TextStyle(
                                fontSize: 19 * unitHeightValue,
                                color: Colors.grey[600],
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.normal),
                          ),
                        ]),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      if(_formKey.currentState!.validate()) {
                        var isNetwork = ConnectivityState.connectivityState.isNetworkAvailable();
                        if(isNetwork == true) {
                          emailOTPVerification();
                        }else{
                          ConnectivityState.showCustomDialog(context,
                              title: 'Please make sure you are connected to internet and try again',
                          okBtnText: 'Okay');
                        }
                      } else {
                        print('otp failure');
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 60),
                      height: 35,
                      width: 35,
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: ExactAssetImage(
                            'images/otp_page_next_btn_3x.png',
                          ),
                          fit: BoxFit.contain
                        )
                      ),
                    ),
                  )

                ],
              ),
            ),
          ),
        ),

      ),
    );
  }
}
