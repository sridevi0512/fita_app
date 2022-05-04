
import 'dart:convert';

import 'package:first_app/homepage.dart';
import 'package:first_app/utils/apiUrl.dart';
import 'package:first_app/utils/constants.dart';
import 'package:first_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'emailotp.dart';

class RegisterScreen extends StatefulWidget {
  String userId, firstName, lastName, email, token, auth;


  @override
  _RegisterScreenState createState() => _RegisterScreenState();
  RegisterScreen({Key? key,

    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.token,
    required this.auth})
      : super(key: key);
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _nameEditingController = new TextEditingController();
  TextEditingController _lastNameEditingController = new TextEditingController();
  TextEditingController _emailEditingController = new TextEditingController();
  TextEditingController _mobileEditingController = new TextEditingController();

  var _formKey = GlobalKey<FormState>();
  bool _validate = false;
  bool checkBoxValue = false;
  bool emailEdit = false;
  late bool otpNeed;

  showLoaderDialog(BuildContext context){
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
            margin: EdgeInsets.only(left: 7),
            child: Text("Loading...."),

          )
        ],
      ),
    );
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return alert;
        }
    );
  }

  Future<String?> emailUpdateApi() async {
    showLoaderDialog(context);
    final response = await http.post(
        Uri.parse(ApiUrl.BASE_URL + ApiUrl.EMAIL_UPDATE),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': Preference.getAuthToken(Constants.AUTH_TOKEN)
        },
        body: jsonEncode({
          'email': _emailEditingController.text,
          'user_id': Preference.getUserId(Constants.USER_ID),
          'otp_need': otpNeed
        })
    );
    if (response.statusCode == 200) {
      Navigator.pop(context);
      var data = json.decode(response.body);
      print(data);
      _formKey.currentState!.reset();
      if (otpNeed == true) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) {
              return EmailOTP();
            },
                settings: RouteSettings(
                  name: 'registration_screen',
                )
            )
        );
      } else {
        print('MAIL - GMAIL: Calling Profile update API');
        profileUpdateApi();
      }

      Fluttertoast.showToast(msg: data['status']['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
    else {
      print(""
          "MAIL - EMAIL UPDATE");
      FocusScope.of(context).requestFocus(new FocusNode());
      var data = json.decode(response.body);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: data['status']['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      print(data['status']['message']);
    }
  }

  //profileUpdate Api
  Future<String?> profileUpdateApi() async{
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
    if(response.statusCode == 200){
      Preference.setEmailVerified(Constants.EMAIL_VERIFIED, true);
      var data = json.decode(response.body);
      print(data);
      Navigator.of(context).popUntil((route) {
        return route.settings.name == 'gmail_screen';
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(
        receiveCourseIdentity: 0,
      )));
      Fluttertoast.showToast(msg: data['status']['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }else{
      print("PROFILE-UPDATE ELSE");
      var data = json.decode(response.body);
      print(data['status']['message']);
      Fluttertoast.showToast(msg: data['status']['message'],toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.BOTTOM);
    }

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("auth-token: ${Preference.getAuthToken(Constants.AUTH_TOKEN)}");
    _mobileEditingController.text =
        Preference.getMobileNumber(Constants.MOBILE_NUMBER);
    if(this.widget.auth == 'gmail') {
      _nameEditingController.text = this.widget.firstName;
      _lastNameEditingController.text = this.widget.lastName;
      _emailEditingController.text = this.widget.email;
      emailEdit = true;
      otpNeed = false;
    } else {
      otpNeed = true;
      emailEdit = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
    onTap: () {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    },
        child:SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            toolbarHeight: MediaQuery.of(context).size.height * 0.15,
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  child: IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios),
                    iconSize: 18,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Back",
                  style: TextStyle(color: Colors.black,fontSize: 16),
                ),
              ],
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                        "images/fita_app_background_xxhdpi_3x.png"),
                    fit: BoxFit.cover
                )
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: 20.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameEditingController,
                      validator: (value) {
                        if(value!.length == 0) {
                          return 'Enter the first name';
                        } else{
                          return null;
                        }
                      },
                      onChanged: (value) {
                        setState(() {

                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'First Name',
                        fillColor: Color.fromARGB(100, 230, 230, 230),
                        filled: true,
                        contentPadding: EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(75.0)),
                          borderSide: BorderSide.none,
                        ),
                        labelStyle: TextStyle(fontSize: 24,color: Colors.black),

                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameEditingController,
                      validator: (value) {
                        if(value!.length == 0) {
                          return 'Enter the last name';
                        }else{
                          return null;
                        }
                      },
                      onChanged: (value) {
                        setState(() {

                        });
                      },
                      decoration: InputDecoration(
                          hintText: 'Last Name',
                          fillColor: Color.fromARGB(100, 230, 230, 230),
                          filled: true,
                          contentPadding: EdgeInsets.all(10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(75.0),
                            borderSide: BorderSide.none,

                          ),
                          labelStyle: TextStyle(fontSize: 24,color: Colors.black)
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailEditingController,
                      readOnly: emailEdit,
                      validator: (value) {
                        String pattern =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regExp = new RegExp(pattern);
                        if(value!.length == 0){
                          return 'Email is required';

                        }else if(!regExp.hasMatch(value)) {
                          return "Invalid Email Address";
                        }else{
                          return null;
                        }
                      },
                      onChanged: (value) {
                        setState(() {

                        });
                      },
                      decoration: InputDecoration(
                          hintText:'E-Mail Address',
                          filled: true,
                          fillColor: Color.fromARGB(100, 230, 230, 230),
                          contentPadding: EdgeInsets.all(10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(75.0),
                              borderSide: BorderSide.none
                          ),
                          labelStyle: TextStyle(fontSize: 24,color: Colors.black)
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _mobileEditingController,
                      enabled: false,
                      decoration: InputDecoration(
                          fillColor: Color.fromARGB(100, 230, 230, 230),
                          filled: true,
                          contentPadding: EdgeInsets.all(10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(75.0),
                              borderSide: BorderSide.none
                          ),
                          labelStyle: TextStyle(fontSize: 24,color: Colors.black)
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Checkbox(
                            value: checkBoxValue,
                          onChanged: (bool? value) {
                            setState(() {
                              checkBoxValue = value!;
                            });
                          },
                        ),
                        Text(
                          "I agree the terms and conditions"),
                      ],
                    ),
                    SizedBox(width: 175,
                    child: RaisedButton(
                      padding:EdgeInsets.symmetric(vertical: 0.0,horizontal: 30.0),
                      onPressed: (){
                        if(_formKey.currentState!.validate()){
                          if(checkBoxValue){
                            if(otpNeed== true) {
                              Preference.setFirstName(Constants.FIRST_NAME, _nameEditingController.text.toString());
                              Preference.setLastName(Constants.LAST_NAME, _lastNameEditingController.text.toString());
                              Preference.setEmail(Constants.EMAIL, _emailEditingController.text.toString());
                              print('Register: EDIT TEXT Email ' +
                                  _emailEditingController.text);
                              print('Register: Email Id ' +
                                  Preference.getEmail(Constants.EMAIL));
                              print('Register: User Id ' +
                                  Preference.getUserId(Constants.USER_ID));
                              print('Register: OTP Need ' + otpNeed.toString());
                              print('Register: First Name ' +
                                  Preference.getFirstName(
                                      Constants.FIRST_NAME));
                              print('Register: Last Name ' +
                                  Preference.getLastName(Constants.LAST_NAME));
                              print('Register EDIT TEXT: First Name ' +
                                  _nameEditingController.text);
                              print('Register EDIT TEXT: Last Name ' +
                                  _lastNameEditingController.text);
                              emailUpdateApi();
                            }else {
                              print('Register: GMAIL' + _emailEditingController.text);
                              print('Register: USER ID' + Preference.getUserId(Constants.USER_ID));
                              print('Register: OTP Need' + otpNeed.toString());
                              Preference.setFirstName(Constants.FIRST_NAME, _nameEditingController.text.toString());
                              Preference.setLastName(Constants.LAST_NAME, _lastNameEditingController.text.toString());
                              Preference.setEmail(Constants.EMAIL, _emailEditingController.text.toString());
                              emailUpdateApi();
                            }
                          } else {
                            Fluttertoast.showToast(msg: "Please agree the terms and conditions",
                                gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_SHORT);
                          }
                        }else{
                          print("register-failure");
                          setState(() {
                            _validate = true;
                          });
                        }

                      },
                      color: Color(0XFFE82A01),
                      shape: RoundedRectangleBorder(
                        borderRadius:BorderRadius.circular(30.0)
                      ),
                      child: Text(
                        "Register",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    )
                  ],
                ),
              ),
            ),
          ),
        )
        )
    );
  }
}
