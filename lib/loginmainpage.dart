import 'dart:convert';

import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/connectivity.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'otppage.dart';

class LoginMainPage extends StatefulWidget {
  const LoginMainPage({Key? key}) : super(key: key);

  @override
  _LoginMainPageState createState() => _LoginMainPageState();
}

class _LoginMainPageState extends State<LoginMainPage> {
  TextEditingController numbercontroller = new TextEditingController();
  late String userId, mobileNumber;
  bool _validate = false;
  bool _loading = false;
  late FocusNode _focusNode;
  var wifiBSSID;
  var wifiIP;
  var wifiName;
  bool isWifiConnected = false;
  bool isInternetOn = true;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var _text = '';
  bool isLoggedIn = false;
  String someString ='';


  Future<String?> login() async{

    print(ApiUrl.BASE_URL + ApiUrl.MOBILE_NUMBER);
    showLoaderDialog(context);
    print("mobile_number:${(numbercontroller.text.toString())}");
    final response = await  http.post(Uri.parse(ApiUrl.BASE_URL+ ApiUrl.MOBILE_NUMBER),
        headers: <String,String>{
          'content-type':'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String,String>{
          'mobile_number': numbercontroller.text,
          'role':'user',

        }));

    try{
      var data = json.decode(response.body);
      if(data["status"]['status'] == 'Success'){
        Navigator.pop(context);
        _loading=false;
        userId =data['data']['_id'];
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString("user_id", data['data']['_id']);
        Preference.setUserId(Constants.USER_ID, data['data']['_id']);
        Preference.setMobileNumber(Constants.MOBILE_NUMBER, data['data']['mobile_number']);
        mobileNumber = data['data']['mobile_number'];
        Navigator.push(context, PageRouteBuilder(pageBuilder: (context,animation1, animation2) {
          return OtpPage(
            userId: userId,
            mobileNumber: mobileNumber,
          );
        },
            transitionsBuilder: (context,animation1,animation2,child){
              return FadeTransition(
                child: child,
                opacity: animation1,
              );
            },
            transitionDuration: Duration(milliseconds: 1)));

        formKey.currentState?.reset();
        numbercontroller.clear;

        Fluttertoast.showToast(msg: data['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      }else{

        Navigator.pop(context);
        _loading = false;
        Fluttertoast.showToast(msg: data['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      }


    }catch(Exception){
      FocusScope.of(context).requestFocus(new FocusNode());
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "The Server is temporarily unable to service your request",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT);
    }


  }
  @override
  void initState() {
    // TODO: implement initState
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      FocusScope.of(context).requestFocus(null);
      if(_focusNode.hasFocus) numbercontroller.clear();
    });
    super.initState();
  }

  @override
  void dispose() {
    numbercontroller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child:SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body:Container(
            decoration: BoxDecoration(
              image: new DecorationImage(
                  image: ExactAssetImage("images/fita_app_bakground_xxhdpi_3x.png"),fit: BoxFit.cover),
            ),
            child: GestureDetector(
              onTap: (){
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Container(
                child: new Form(
                  key: formKey,
                   autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Flexible(child:
                        Container(
                          height: MediaQuery.of(context).size.height * 0.45,
                          alignment: Alignment.bottomLeft,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: ExactAssetImage(
                                      'images/mobile_number_screen_bg.png'),
                                  fit: BoxFit.fill)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 70, horizontal: 35),
                            child: Text(
                              'Enter your\nMobile number',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                        Row(

                          children: [
                            SizedBox(width: 30.0),
                            Text(
                              'You will get a code via sms',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.0),
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                        Padding(
                          padding:

                          const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                          child: new Row(

                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Container(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: AbsorbPointer(
                                  absorbing: true,
                                  child: Padding(
                                    child: new TextField(
                                      maxLength: 3,
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xff757575), width: 2.0),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xff757575), width: 2.0),
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xff757575), width: 2.0),
                                        ),
                                        contentPadding: EdgeInsets.all(10),
                                        counter: Text(" "),
                                        hintText: '+91',
                                        hintStyle: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(
                                        bottom:
                                        MediaQuery.of(context).viewInsets.bottom),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Flexible(
                                child: Container(

                                  width: MediaQuery.of(context).size.width * 0.52,
                                  child: Padding(

                                    child: TextFormField(
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                          decoration: TextDecoration.none,
                                          letterSpacing: 5),

                                      maxLength: 10,
                                      controller: numbercontroller,
                                      validator: (value) {
                                        String patttern = r'(^[0-9]*$)';
                                        RegExp regExp = new RegExp(patttern);
                                        if (value!.length == 0) {
                                          return "Mobile Number is Required";
                                        } else if (value.length != 10) {
                                          return "Should be 10 digits";
                                        } else if (!regExp.hasMatch(value)) {
                                          return "Should be in digits";
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                      keyboardType: TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xff757575), width: 2.0),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xff757575), width: 2.0),
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xff757575), width: 2.0),
                                        ),
                                        contentPadding: EdgeInsets.all(10),
                                        hintText: 'Your Mobile Number',
                                        counter: Text(" "),
                                        hintStyle: TextStyle(
                                          letterSpacing: 0,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(
                                        bottom:
                                        MediaQuery.of(context).viewInsets.bottom),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              print('Number success');
                              var isNetwork = await ConnectivityState
                                  .connectivityState
                                  .isNetworkAvailable();
                              if (isNetwork == true) {
                                login();
                              } else {
                                ConnectivityState.showCustomDialog(
                                  context,
                                  title:
                                  'Please make sure you are connected to internet and try again',
                                  okBtnText: 'Okay',
                                );
                              }
                            } else {
                              print('Number error');
                              setState(() {
                                _validate = true;
                              });
                            }

                          },
                          child: Container(

                              margin: const EdgeInsets.only(top: 60),
                              height: 35.0,
                              width: 35.0,
                              alignment: Alignment.bottomCenter,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: ExactAssetImage(
                                          'images/otp_page_next_btn_3x.png'),
                                      fit: BoxFit.contain))),
                        ),
                      ],
                    ),
                ),
              ),

            ),
/*
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
                    "Enter Your \n Mobile \n Number",
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
                      "You will get a code \n via sms",
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
                  children:   [
                    Padding(padding: EdgeInsets.all(8.0),
                        child: Text(
                          "+91",
                          style: TextStyle(
                              color: Colors.transparent,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              shadows: [
                                Shadow(offset: Offset(0, -13), color: Color(0xff797979))
                              ],
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xff797979),
                              decorationThickness: 3

                          ),
                        )
                    ),
                    Flexible(

                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0,right: 20.0,bottom: 8.0),

                          child: TextField(
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign. center,
                            maxLength: 10,
                            controller: numbercontroller,
                            style: TextStyle(
                                letterSpacing: 5.0,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff797979)
                            ),
                            decoration: InputDecoration(
                                counterText: " ",
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color:Color(0xff797979), width: 3.0),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color:Color(0xff797979), width: 3.0),
                                ),
                                hintText: "Enter Mobile Number",
                                errorText: _errorText,
                                errorStyle: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold),
                                hintStyle: TextStyle(color: Color(0xff797979),
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    decorationColor: Color(0xff797979),
                                    fontWeight: FontWeight.bold)

                            ),
                            onChanged: (value) {
                              if(value.length == 10) {
                                FocusScope.of(context).nextFocus();
                              }
                              setState(() {
                                _text;
                              });
                            },

                          ),
                        )

                    )

                  ],
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if(numbercontroller.text.isEmpty || numbercontroller.text.length <10 ){
                        setState(() {
                          numbercontroller.text.isEmpty || numbercontroller.text.length <10 ? _errorText : null;
                        });
                      }


                      else {
                        login();
                      }

                    },
                    child: Icon(Icons.arrow_forward_ios_rounded,color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20.0),
                      primary: Colors.blue,
                    ),)
                  ,
                )

              ],
            ),
*/

          )
      ),
      )
    );
  }

  String? get _errorText {

    final text = numbercontroller.value.text;

    if (text.isEmpty ||text.length < 10) {
      return 'Enter valid mobile number';
    }
    else{
      return null;
    }



  }

}
