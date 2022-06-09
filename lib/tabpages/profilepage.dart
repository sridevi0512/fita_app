import 'dart:convert';

import 'package:fita_app/assessmentnonlaunch.dart';
import 'package:fita_app/loginmainpage.dart';
import 'package:fita_app/main.dart';
import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:fita_app/utils/sharedpreferences.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../concernstatus.dart';
import '../editprofile.dart';
import '../mycertificatepage.dart';
import '../raisedconcern.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool isLogged = false;
  String firstName = '', lastName = '';
  List<String> _list = [
    "Concern Status",
    "Raise Concern",
    "My Certificate",
    "Feedback"
  ];

  List<String> iconImages = [
    "images/concern_status.png",
    "images/concern_raise.png",
    "images/certificate.png",
    "images/feedback_icon.png"
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Profile");
    if(Preference.getAuthToken(Constants.AUTH_TOKEN) != ""){
      isLogged = false;
    }  else {
      isLogged = true;
    }
    firstName = Preference.getFirstName(Constants.FIRST_NAME);
    lastName = Preference.getLastName(Constants.LAST_NAME);
    print("FirstName: ${firstName}");
    print("LastName: ${lastName}");
  }

  _updateUserName() {
    print("Called");
    firstName = Preference.getFirstName(Constants.FIRST_NAME);
    lastName = Preference.getLastName(Constants.LAST_NAME);
    setState(() {});
  }

  _onBackPressed() {
    setState(() {
      firstName = Preference.getFirstName(Constants.FIRST_NAME);
      lastName = Preference.getLastName(Constants.LAST_NAME);
    });
  }

  Future<String?> logoutApi() async {
    var response;
    response = await http
        .post(Uri.parse(ApiUrl.BASE_URL + ApiUrl.LOGOUT), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN)
    });
    try{
      var data = json.decode(response.body);
      print('Logout try');
      Fluttertoast.showToast(msg: data['status']['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);

      if(response == 200){
        print('Logout 200');
      } else if(response == 400){
        print('Logout 400');
        var data1 = json.decode(response.body);
        Fluttertoast.showToast(msg: data1['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
        print('Else Status ${data1['status']}');
      }
      if(data['status']['status'] == "Success") {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) {
                  return LoginMainPage();
                }
            ),
                (_) => false
        );
        Preference.setAuthToken(Constants.AUTH_TOKEN, "");
        Fluttertoast.showToast(msg: data['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);

      } else {
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) {
                  return LoginMainPage();
                },
                transitionsBuilder: (context, animation1, animation2, child) {
                  return FadeTransition(
                    opacity: animation1,
                    child: child,
                  );
                },
                transitionDuration: Duration(milliseconds: 1)
            )
        );
        Preference.setAuthToken(Constants.AUTH_TOKEN, "");
        Fluttertoast.showToast(msg: "Logged out successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      }
    }catch(Exception ) {
      Fluttertoast.showToast(msg: 'The server is temporarily unable to service your request',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20,top: 10, bottom: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context){
                              Widget cancelButton = TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cancel")
                              );

                              Widget logout = TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  prefs.remove("user_id");
                                  Preference.setAuthToken(Constants.AUTH_TOKEN, "");
                                  Preference.setUserId(Constants.USER_ID, "");
                                  Preference.setFirstName(Constants.FIRST_NAME, "");
                                  Preference.setLastName(Constants.LAST_NAME, "");
                                  print("SetUSERID: ${Preference.getUserId(Constants.USER_ID)}");
                                  logoutApi();
                                },
                                child: Text("Logout"),
                              );

                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                title: Text('Are you sure want to logout?'),
                                actions: [cancelButton,logout],
                              );
                            },
                          );
                        });
                      },
                      child: Image.asset(
                        "images/power_icons.png",
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                        color: Colors.red,

                      ),
                    ),
                    Image.asset(
                      "images/contact_icon.png",
                      width: 35,
                      height: 35,
                      fit: BoxFit.cover,
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: Container(
                      alignment: Alignment.center,
                      child: (Preference.getFirstName(Constants.FIRST_NAME) == "") ?
                          Text(""):
                      Text(
                        '${Preference.getFirstName(Constants.FIRST_NAME)[0]}'
                            '${Preference.getLastName(Constants.LAST_NAME)[0]}'
                            .toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue
                      ),

                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Text(firstName + " " + lastName,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize:18
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: (){
                    Navigator.of(context)
                        .push(
                        MaterialPageRoute(
                            builder: (_) => new EditProfile() )
                    ).then((value) => value!= null ? _updateUserName() : null);
                  },
                  child: Container(
                    child: Text(
                      "Manage Profile",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 14
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  child: Divider(
                    height: 1,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Expanded(
                    child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: (16/9),
                        children:
                        List.generate(_list.length, (index) {
                          return GestureDetector(
                            onTap: (){
                              setState(() {
                                if(index == 0) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ConcernStatusClass()
                                      )
                                  );
                                } else if (index == 1){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RaiseConcernClass()
                                      )
                                  );
                                } else if(index == 2){
                                  print("Certificate");
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyCertificate() ));
                                }
                              });
                            },
                            child: Card(
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.0),

                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          iconImages[index],
                                          width: 35,
                                          height: 35,
                                          fit: BoxFit.cover,
                                        ),

                                        SizedBox(
                                          height: 5,
                                        ),
                                        Flexible(
                                          child:ClipRRect(
                                            borderRadius: BorderRadius.circular(3),
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 3,right: 3),
                                              child: Text(
                                                _list[index],
                                                maxLines: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        )
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
