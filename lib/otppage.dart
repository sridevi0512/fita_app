import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:device_info/device_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:first_app/gmailscreen.dart';
import 'package:first_app/main.dart';
import 'package:first_app/utils/apiUrl.dart';
import 'package:first_app/utils/connectivity.dart';
import 'package:first_app/utils/constants.dart';
import 'package:first_app/utils/preference.dart';
import 'package:first_app/utils/sharedpreferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
// import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'homepage.dart';

class OtpPage extends StatefulWidget {
  String userId, mobileNumber;
  OtpPage({Key? key, required this.userId,required this.mobileNumber}) : super(key: key);

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _fieldOne = TextEditingController();
  final TextEditingController _fieldTwo = TextEditingController();
  final TextEditingController _fieldThree = TextEditingController();
  final TextEditingController _fieldFour = TextEditingController();
  var formKey = GlobalKey<FormState>();
  bool _resendOtp = false;
  bool _validate = false;
  SharedPreference prefs = SharedPreference();
  SharedPreferences? preferences;
  Timer? _timer;
  final interval =const Duration(seconds: 1);
  final int timermaxSeconds = 180;
  int currentSeconds =0;
  double? unitHeightValue;
  static String deviceName = '';
  static String deviceVersion = '';
  static String identifier= '';
  String token= '';
  String otp = '';

  String get timerText =>'${((timermaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2,'0')} : ${((timermaxSeconds - currentSeconds) % 60).toString().padLeft(2,'0')}';

  startTimerOut([int? milliseconds]) {
    var duration =interval;
    _timer =new Timer.periodic(duration, (timer) {
      setState(() {

        currentSeconds = timer.tick;
        if(timer.tick >= timermaxSeconds) {
          timer.cancel();
          _resendOtp = true;
        }
      });
    });

  }

  static Future<List<String>> getDeviceDetails() async{
    final DeviceInfoPlugin deviceInfoPlugin =new DeviceInfoPlugin();
    try{
      if(kIsWeb){
        WebBrowserInfo webBrowserInfo = await deviceInfoPlugin.webBrowserInfo;
        deviceName = describeEnum(webBrowserInfo.browserName);
        deviceVersion = "web";
        identifier = webBrowserInfo.userAgent!;
        print("Device version: ${identifier}");
        print("Device Info:" + deviceName + "\n"
            + deviceVersion + "\n" +
        identifier);
        // identifier = webInfo.userAgent!;
      }
      else if(Platform.isAndroid) {
        var build =await deviceInfoPlugin.androidInfo;
        deviceName = build.model!;
        deviceVersion = "android";
        identifier = build.androidId!;
        print("DeviceDetails:" + deviceName + "\n"
            + deviceVersion + "\n"
            + identifier);
      }else if(Platform.isIOS){
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name!;
        deviceVersion = 'ios';
        identifier = data.identifierForVendor!;
        print("Device Info:" + deviceName + "\n"
        + deviceVersion + "\n" +
        identifier );
      }


    }on PlatformException{
      print("Failed to get device id");
    }
    return [deviceName,deviceVersion,identifier];

  }
  @override
  void initState() {
    // TODO: implement initState
    startTimerOut();
    getDeviceDetails();
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _timer!.cancel();
    super.dispose();

  }

  Future<String?> otpVerification() async {
     showLoaderDialog(context);
    var response;
    if(_resendOtp) {
      print("resend");
      print("otpmobilenumber: ${(widget.mobileNumber)}" );
      print("otpuserid: ${(widget.userId)}");
      print("otp_resend: ${(ApiUrl.BASE_URL+ApiUrl.OTP_RESEND)}" );
      response = await http.post(Uri.parse(ApiUrl.BASE_URL + ApiUrl.OTP_RESEND),
      headers: <String,String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String,String>{
        'mobile_number': widget.mobileNumber,
        'user_id': widget.userId,
      }));
      try{
        var data = jsonDecode(response.body);
        if(response.statusCode == 200) {
          FocusScope.of(context).requestFocus(FocusNode());
          Navigator.of(context).pop();
          Fluttertoast.showToast(msg: data['status']['message'],gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
          print(data['status']['message']);
        }else{
          FocusScope.of(context).requestFocus(FocusNode());
          Navigator.of(context).pop();
          Fluttertoast.showToast(msg: data['status']['message'],gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
          print(data['status']['message']);
        }
      }catch(Exception) {
        FocusScope.of(context).requestFocus(FocusNode());
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: 'The server is temporarily unable to service your request',
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT);

      }
    }else{
      print("otp");
      response = await http.post(Uri.parse(ApiUrl.BASE_URL + ApiUrl.OTP_VERIFY),
        headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },body: jsonEncode(<String,String> {
        'mobile_otp' :otp,
            'user_id': widget.userId,
            'device_name':deviceName,
            'device_id':identifier,
            'device_type':deviceVersion,
            'firebaseauth_token':
            Preference.getFirebaseToken(Constants.FIREBASE_TOKEN),

          }) );
      try{
        var jsonBody = jsonDecode(response.body.toString());
        print("data_user: $jsonBody");
        if(response.statusCode == 200){
          _timer!.cancel();
          if(jsonBody['status']['status'] == "Success") {
            print("&&&&&");
            _resendOtp = true;
            formKey.currentState!.reset();
            token = jsonBody['session']['token'];
            print("token: ${(jsonBody['session']['token'])}");
            Preference.setAuthToken(
                Constants.AUTH_TOKEN, jsonBody['session']['token']);


              print("first_name: ${(jsonBody['data']['first_name'])}");
              if(jsonBody['data']['first_name']!= null){
                Preference.setFirstName(
                    Constants.FIRST_NAME, jsonBody['data']['first_name']);
                Preference.setLastName(
                    Constants.LAST_NAME, jsonBody['data']['last_name']);
                Preference.setEmail(Constants.EMAIL, jsonBody['data']['email']);
              }



            Preference.setEmailVerified(
                Constants.EMAIL_VERIFIED, jsonBody['data']['email_verified']);
            Preference.setMobileVerified(
                Constants.MOBILE_VERIFIED, jsonBody['data']['mobile_verified']);
            if (jsonBody['data']['email_verified'] == false) {
              Fluttertoast.showToast(msg: "Email not verified",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM);
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) {
                    return GmailScreen(
                      userId: widget.userId,
                          userToken: token,
                    );
                  },
                  transitionsBuilder: (context, animation1, animation2, child) {
                    return FadeTransition(
                      opacity: animation1,
                      child: child,
                    );
                  },
                  transitionDuration: Duration(milliseconds: 1),
                ),
              );
              print('email verified');
            } else if (jsonBody['data']['mobile_verified'] == false) {
              _resendOtp = true;
              print('mobile verified');
              Fluttertoast.showToast(msg: "mobile not verified",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM);
            } else {
              print('home screen');
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomePage(
                             receiveCourseIdentity: 0,
                          )));
            }
            Fluttertoast.showToast(msg: jsonBody['status']['message'],
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_SHORT);

          }
         else {
          FocusScope.of(context).requestFocus(new FocusNode());
          Navigator.pop(context);

          formKey.currentState!.reset();
          Fluttertoast.showToast(msg: jsonBody['status']['message'],
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT);

        }
      } else {
    _timer!.cancel();
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.pop(context);
    formKey.currentState!.reset();
    Fluttertoast.showToast(msg: jsonBody['status']['message'],
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
    }
    } catch (Exception) {
    _timer!.cancel();
    FocusScope.of(context).requestFocus(new FocusNode());
    print("Exception: $Exception");
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.pop(context);
    });
    Fluttertoast.showToast(msg: 'The server is temporarily unable to service your request',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
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
              PageRouteBuilder(pageBuilder: (context,animation1,animation2) {
                return SizedBox();
              },
              transitionsBuilder: (context,animation1,animation2,child){
                return FadeTransition(opacity: animation1,child: child,);
              },
              transitionDuration: Duration(milliseconds: 2000))
              );
            },
            icon: Icon(Icons.arrow_back_ios),
            iconSize: 25,
            color: Colors.black,
          ),
          title: Text(
            "verification",
            style: TextStyle(color: Colors.black, fontSize: 24 * unitHeightValue!),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/courses_bg.png'),
                fit: BoxFit.cover
              )
            ),
            child: new Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'verify Your Mobile',
                    style: TextStyle(
                      wordSpacing: 1,
                      color: Colors.black,
                      fontSize: 35 * unitHeightValue!,
                      fontWeight: FontWeight.w600,

                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.025,
                  ),
                  Text(
                    'Enter your OTP code here',
                    style: TextStyle(
                      fontSize:  20 * unitHeightValue!,
                      color: Colors.grey[600]

                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.020,
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: SizedBox(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 20.0,horizontal: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          new PinEntryTextField(
                            onSubmit: (String pin) {
                              if (pin.length == 4) {
                                otp = pin;
                                otpVerification();
                              }

                              print('Submit Pin entered is $otp');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            text: "Didn't receive the code? ",
                            style: TextStyle(
                                fontSize: 19 * unitHeightValue!,
                                color: Colors.grey[600],
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                              text: "Click here...",
                              style: TextStyle(
                                  fontSize: 20 * unitHeightValue!,
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
                                    //_resendOtp = true;
                                    if (_resendOtp) {
                                      otpVerification();
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
                                fontSize: 19 * unitHeightValue!,
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
                      if(formKey.currentState!.validate()) {
                        var isNetwork = await ConnectivityState.connectivityState.isNetworkAvailable();
                        if(isNetwork == true){
                          _resendOtp = false;
                          otpVerification();
                        } else {
                          ConnectivityState.showCustomDialog(context, title: "please make sure you are connected to internet and try again",
                          okBtnText: 'Okay');
                        }
                      }else {
                        print('otp failure');
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 40),
                      height: 35.0,
                      width: 35.0,
                        alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: ExactAssetImage(
                            "images/otp_page_next_btn_3x.png"
                          ),
                          fit: BoxFit.contain
                        )
                      ),
                    ),
                  )

                ],
              ),
            )
          ),
        ),
      ),
    );
/*
    return Scaffold(
        body:Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      "images/logo.jpg",
                      fit:BoxFit.fill,
                    ),

                  ),
                  SizedBox(width: 5),
                  Center(
                    child: ElevatedButton(onPressed: (){
                      Navigator.of(
                          context
                      ).pop;
                    },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(width:2.0,color: Color(0xff0773d5))
                                )
                            )
                        ),


                        child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child:Text('SignUp\n /Login',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:  TextStyle(color:Colors.black,
                                  fontWeight: FontWeight.bold),)
                        )

                    ),
                  )


                ],
              ),
              const Center(
                child: Text(
                  "Verify Your \n Mobile" ,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xff1a2296),
                      fontWeight: FontWeight.bold,
                      fontSize: 35.0
                  ),
                ),
              ),
              const Center(
                  child:Text(
                    "Enter your OTP code here",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xff797979),
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0
                    ),
                  )
              ),
              SizedBox(height: 20.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OtpInput(_fieldOne,true),
                  OtpInput(_fieldTwo,false),
                  OtpInput(_fieldThree,false),
                  OtpInput(_fieldFour,false)
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: (){
                    setState(() {
                      otp = _fieldOne.text +
                          _fieldTwo.text +
                          _fieldThree.text +
                          _fieldFour.text;
                    });
                    */
/*String otptext = "1234";
                    if(otptext== otp){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePage()));
                    }
                    else{
                      Fluttertoast.showToast(
                          msg: "Invalid OTP",
                          timeInSecForIosWeb: 1,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM);
                    }*//*

                    otpVerification();
                  }, child: Icon(Icons.arrow_forward_ios_rounded,color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20.0),
                    primary: Colors.blue,
                  ),),
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: (){

                },
                child: const Center(
                  child: Text(
                    "Didn't receive the code? \n Click here...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Color(0xff797979)
                    ),
                  ),
                ),
              )

            ],
          ),

        )

    );
*/
  }
}
/*class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool autofocus;

  const OtpInput(this.controller, this.autofocus, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 61,
      child: TextField(
        autofocus: autofocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: Colors.black
        ),
        controller: controller,
        maxLength: 1,
        cursorColor: Theme.of(context).primaryColor,
        decoration:  InputDecoration(
            counterText: '',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color:Color(0xff797979), width: 3.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color:Color(0xff797979), width: 3.0),
            ),
            hintStyle: TextStyle(color: Color(0xff797979),fontSize: 20.0)
        ),
        onChanged: (value) {
          if(value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}*/

