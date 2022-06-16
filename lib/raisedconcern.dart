import 'dart:convert';

import 'package:fita_app/main.dart';
import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/connectivity.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class RaiseConcernClass extends StatefulWidget {
  const RaiseConcernClass({Key? key}) : super(key: key);

  @override
  _RaiseConcernClassState createState() => _RaiseConcernClassState();
}

class _RaiseConcernClassState extends State<RaiseConcernClass> {
  // String _selectedText = "SSD";
  var currentSelectedValue;
  // static const deviceTypes = ["Mac, Windows","Mobile"];
  var batchList = [];
  String courseName = '', batchCode = '';
  List data = [];
  var _formKey = GlobalKey<FormState>();
  TextEditingController concernController = new TextEditingController();
  TextEditingController batchController = new TextEditingController();
  FocusNode _focusNode = FocusNode();
  bool visible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    batchCodeList();
  }

  Future<String?> batchCodeList() async {
    final response = await http.get(
      Uri.parse(ApiUrl.BASE_COURSE_URL + ApiUrl.BATCH_LIST),
      headers:<String, String>{
        'Content-Type': 'application/json',
        'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
      },
    );
    if(response.statusCode == 200){
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data'];
      setState(() {
        this.batchList = data;
        this.data = data;
      });
      if(this.batchList.isEmpty) {
        showAlertDialog(context);
      }
    }
  }

  showAlertDialog(BuildContext context){
    AlertDialog dialog = new AlertDialog(
      content: Text("No batches found"),
      actions: <Widget>[

        TextButton(
          child: const Text('Okay'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            Navigator.of(context).pop();

          },
        ),
      ],
    );
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Future<String?> raiseConcernApi() async {
    // showLoaderDialog(context);
    FocusScope.of(context).unfocus();
    final response = await http.post(
        Uri.parse(ApiUrl.BASE_COURSE_URL + ApiUrl.RAISE_CONCERN),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
        },
        body: jsonEncode({
          "batch_code": batchCode,
          "concernmessage": concernController.text
        })
    );
    var jsonData = jsonDecode(response.body);
    try{
      if(response.statusCode == 200){
        Navigator.pop(context);
        var data = jsonData['data'];
        print(data.toString());
        print("BATCH CODE ${batchCode}");
        Fluttertoast.showToast(msg: jsonData['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white);
        Navigator.pop(context);
        setState(() {});
      } else {
        print(concernController.text);
        Fluttertoast.showToast(msg: jsonData['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
        Navigator.pop(context);
        print("Notification error in TRY");
      }
    } catch (Exception) {
      print("Notification error in CATCH");
      Navigator.pop(context);
      print("Exception ${Exception}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (){
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child:Scaffold(
          appBar: AppBar(
            title: Text('Raise a Concern'),
          ),
          body: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      FormField(
                        builder: (FormFieldState<String> state){
                          return InputDecorator(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5))
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String> (
                                isExpanded: true,
                                hint: Text('Select Batch Code'),
                                value: currentSelectedValue,
                                isDense: true,
                                items: data.map((e) {
                                  return DropdownMenuItem(
                                    child: Text(e['course_name'].toString(),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black
                                      ),
                                    ),
                                    value: e['course_name'].toString(),
                                    onTap: () {
                                      batchCode = e['batch_code'].toString();
                                      print('BC ${e['batch_code'].toString()}');
                                    },
                                  );
                                }).toList() ?? [],
                                onChanged: (value) {
                                  setState(() {
                                    visible = true;
                                    currentSelectedValue = value;
                                    print('Course CSV ' + currentSelectedValue);
                                  });
                                },
                                onTap: () {
                                  setState(() {

                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            currentSelectedValue != null ?
                            Text(batchCode + ':' + currentSelectedValue,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18
                              ),):
                            Text(""),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            Visibility(
                              visible: true,
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: concernController,
                                  textInputAction: TextInputAction.newline,
                                  maxLines: 5,
                                  validator: (value) {
                                    if(value!.length == 0 && value.length < 10) {
                                      return "Please raise your concern more than 10 characters";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Raise your concern',
                                    fillColor: Colors.transparent,
                                    filled: true,
                                    contentPadding: EdgeInsets.all(10),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    labelStyle: TextStyle(
                                        fontSize: 24,
                                        color: Colors.black
                                    ),
                                  ),
                                  focusNode: _focusNode,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: visible,
                              child: RaisedButton(
                                padding: EdgeInsets.symmetric(vertical: 0,horizontal: 30.0),
                                onPressed: () async {
                                  if(_formKey.currentState!.validate()){
                                    var isNetwork = await ConnectivityState.connectivityState
                                        .isNetworkAvailable();
                                    if(isNetwork == true) {
                                      raiseConcernApi();
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
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
