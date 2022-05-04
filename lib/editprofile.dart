import 'dart:convert';

import 'package:first_app/utils/apiUrl.dart';
import 'package:first_app/utils/constants.dart';
import 'package:first_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _firstnameEditingController = new TextEditingController();
  TextEditingController _lastNameEditingController = new TextEditingController();
  TextEditingController _emailEditingController = new TextEditingController();
  TextEditingController _mobileNumEditingController = new TextEditingController();
  var _formKey = GlobalKey<FormState>();
  bool _validate = false;
  bool emailEdit = false;
  String firstName = "" , lastName = "", email = "", mobileNumber = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    viewProfileApi();
    print('NAME: ' + Preference.getFirstName(Constants.FIRST_NAME) +
        " " +
        Preference.getLastName(Constants.LAST_NAME));
  }

  Future<String?> viewProfileApi() async {
    final response = await http.get(
        Uri.parse(ApiUrl.BASE_COURSE_URL + ApiUrl.EDIT_USER_NAME),
        headers: <String,String>{
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),

        }
    );
    if(response.statusCode == 200){
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data'];
      print("ViewProfileDta ${data.toString()}");
      firstName = data['first_name'];
      lastName = data['last_name'];
      email = data['email'];
      mobileNumber = data['mobile_number'];
      setState(() {
        _firstnameEditingController.text = (firstName==null)? "" : firstName;
        _lastNameEditingController.text = (lastName==null)? "" : lastName;
        _emailEditingController.text = email;
        _mobileNumEditingController.text = mobileNumber;
      });

    } else {
      throw Exception('Failed to load');
    }
  }

  Future<String?> updateProfileApi() async {
    FocusScope.of(context).unfocus();
    final response = await http.post(
        Uri.parse(ApiUrl.BASE_COURSE_URL + ApiUrl.UPDATE_USER_NAME),
        headers: <String,String>{
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
        },
        body: jsonEncode({
          'first_name' : _firstnameEditingController.text,
          'last_name': _lastNameEditingController.text
        })
    );
    var jsonData = jsonDecode(response.body);
    try{
      if(response.statusCode == 200) {
        Navigator.pop(context,true);
        var data = jsonData['data'];
        Fluttertoast.showToast(msg: jsonData['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
        Preference.setFirstName(Constants.FIRST_NAME, data['first_name']);
        Preference.setLastName(Constants.LAST_NAME, data['last_name']);
        setState(() {});
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: jsonData['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      }
    } catch (Exception) {
      Navigator.pop(context);
      var data1 = jsonData['data'];
      print("Error ${data1.toString()}");
      print("Exception: ${Exception}");
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child:Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [],
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/courses_bg.png'),
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
                  controller: _firstnameEditingController,
                  validator: (value) {
                    if(value!.length == 0) {
                      return 'Enter the first name';
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                      hintText: 'First Name',
                      fillColor: Color.fromARGB(100, 230, 230, 230),
                      filled: true,
                      contentPadding: EdgeInsets.all(10.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(75),
                          borderSide: BorderSide.none
                      ),
                      labelStyle: TextStyle(
                          fontSize: 24,
                          color: Colors.black
                      )
                  ),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameEditingController,
                  validator: (value) {
                    if(value!.length == 0) {
                      return 'Enter the last name';
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value){
                    setState(() {});
                  },
                  decoration: InputDecoration(
                      hintText: 'Last Name',
                      fillColor: Color.fromARGB(108, 230, 230, 230),
                      filled: true,
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(75),
                          borderSide: BorderSide.none
                      ),
                      labelStyle: TextStyle(fontSize: 24,color: Colors.black)
                  ),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailEditingController,
                  readOnly: true,
                  style: TextStyle(color: Colors.grey),
/*                      validator: (value) {
                        String pattern =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regExp = new RegExp(pattern);
                        if(value!.length == 0) {
                          return "Email is Required";
                        } else if(!regExp.hasMatch(value)) {
                          return "Invalid Email";
                        } else {
                          return null;
                        }
                      },*/
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'E-Mail Address',
                    fillColor: Color.fromARGB(100, 230, 230, 230),
                    filled: true,
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(75),
                        borderSide: BorderSide.none
                    ),
                    labelStyle: TextStyle(fontSize: 24,color: Colors.grey),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _mobileNumEditingController,
                  readOnly: true,
                  style: TextStyle(color: Colors.grey),
                  /*validator: (value){
                        if(value!.length == 0){
                          return 'Mobile Number';
                        } else {
                          return null;
                        }
                      },*/
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                      hintText: 'Mobile Number',
                      fillColor: Color.fromARGB(100, 230, 230, 230),
                      filled: true,
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(75),
                          borderSide: BorderSide.none
                      ),
                      labelStyle: TextStyle(fontSize: 24, color: Colors.black)
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 0,horizontal: 30),
                    onPressed: (){
                      if(_formKey.currentState!.validate()){
                        updateProfileApi();
                        print('Success');
                      } else {
                        print('Update failure');
                        setState(() {
                          _validate = true;
                        });
                      }
                    },
                    color: Color(0xFFE82A01),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
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
