


import 'dart:convert';
import 'dart:io';

import 'package:fita_app/main.dart';
import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'assessmentCourse.dart';

class Assessment extends StatefulWidget {
  String token;


  @override
  _AssessmentState createState() => _AssessmentState();
  Assessment({Key? key, required this.token}) : super(key: key);
}

class _AssessmentState extends State<Assessment> {
  int? checkingvalue = -1;
  var arrayValue = [];
  var identifyValue = "fgdf";
  List<String> lastData = ["1"];
  List<String> store = [];

  String assessmentId = "1";
  String assessmentIdPrefix ='';
  String? backWardStr;
  String removedBrackets = '';
  List<String> strArr = [];

  String? finalAssessmentID;
  String forMyChecking = "";
  String senddatajson = '';
  String apiCheck = "";
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    assessmentApi();
    this.checkingvalue = -1;
    print("always cal");

  }

  Future<bool> _onBackPressed() {
    if (apiCheck == ApiUrl.BASE_URL_Test+"users/assessment/1/1") {
      Navigator.pop(context);
      print('previous button hit');
    } else {
      print('previous button not hit');
    }
    store.removeLast();
    lastData.removeLast();

    removedBrackets = store.toString().replaceAll("[", "").replaceAll("]", "");
    print("removedBrackets1: $removedBrackets");
    print("store1: $store");
     previous();
    return Future<bool>.value(true);

  }


  Future<String?> secondTimeServerCall(String assessment) async {
    // apiCheck = "";
    // showLoaderDialog(context);

    // String token = await Preference.getAuthToken(Constants.AUTH_TOKEN);
    final response = await http.get(Uri.parse(
        ApiUrl.BASE_URL_Test+'users/assessment/' +
            assessmentIdPrefix +
            '/1' +
            assessment),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
      },
    );

    print('API Second AIP ' + assessmentIdPrefix);
    print('API Second ASS ' + assessment);
    print('API Second Time ' +
        ApiUrl.BASE_URL_Test+'users/assessment/' +
        assessmentIdPrefix +
        '/1' +
        assessment);

    if (response.statusCode == 200) {
      isLoading = true;
      var jsonData = jsonDecode(response.body);
      print(jsonData);
      var data = jsonData['data']['assessment'];

      backWardStr = jsonData['data']['assessment_identifier_second_parameter'];
      print("backWardStr==> : ${backWardStr}");
      setState(() {
        this.identifyValue = "assessmentApi";
        arrayValue = data;
        checkingvalue = -1;
        // Navigator.pop(context);
      });
    } else {
      print("else condition");
      isLoading = true;
      // checkingvalue = null;
      try {
        var ids = strArr;
        print("ids : ${ids}");

        var distinctIds = ids.toSet().toList();
        print("distinctIds : ${distinctIds}");

        var str = jsonEncode(distinctIds);
        var ab = json.decode(str);
        String s = ab.join(',').toString();
        print("tttttttttt : ${s.substring(0, s.length - 3)}");

        Map senddata = {"assessment_course_condition": s};
        senddatajson = json.encode(senddata);
        print("sendData : ${senddatajson}");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AssessmentCourse(
                  receivedJsonData: senddatajson,
                  token: widget.token,
                )));
        setState(() {});
          //this.identifyValue = "assessmentApi";
          print("removelast"+store.removeLast());
        print("store: $store");

          checkingvalue = null;
          strArr.removeLast();
        store.removeLast();
          lastData.removeLast();
          removedBrackets =
              store.toString().replaceAll("[", "").replaceAll("]", "");
          print("removedBrackets1 :${removedBrackets}");


      } catch (Exception) {
        print('Catch exception');
      }
    }

  }

  Future<String?> assessmentApi() async {
    print('First time in  api call');
    apiCheck = ApiUrl.BASE_URL_Test+"users/assessment/1/1";

    final response = await http.get(
      Uri.parse(ApiUrl.BASE_URL_Test+'users/assessment/1/1'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN)
      },
    );
    var data = json.decode(response.body);
    if (response.statusCode == 200) {
      isLoading = true;
      var jsonData = jsonDecode(response.body);
      print(jsonData);
      var data = jsonData['data']['assessment'];
      print("assessmentValues=>: ${data}");
      identifyValue = "assessmentApi";

      setState(() {
        arrayValue = data;
      });
    } else {
      Fluttertoast.showToast(
          msg: data['status']['message'], toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  Future<String?> previous() async {
    arrayValue = [];
    // showLoaderDialog(context);
    final response = await http.get(Uri.parse(
        ApiUrl.BASE_URL_Test+'users/assessment/' + lastData.last +
            '/1' +
            removedBrackets),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN)
      },
    );
    print('API Previous Las ' + lastData.last);
    print('API Previous Rmv ' + removedBrackets);
    print('API Previous ' +
        ApiUrl.BASE_URL_Test+'users/assessment/' +
        lastData.last +
        '/1' +
        removedBrackets);
    apiCheck = ApiUrl.BASE_URL_Test+'users/assessment/' +
        lastData.last +
        '/1' +
        removedBrackets;
    if (response.statusCode == 200) {
      isLoading = true;
      var jsonData = jsonDecode(response.body);
      print(jsonData);
      var data = jsonData['data']['assessment'];
      print("previousAssessmentValues==> : ${data}");

      if(this.mounted){
        setState(() {
          checkingvalue = -1;
          arrayValue = data;
          strArr.removeLast();
        });
      }

    } else {
      // Navigator.pop(context);
      throw Exception('Failed to load');
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: SafeArea(
          child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/courses_bg.png'),
                    fit: BoxFit.cover,
                  )
              ),
              child: Column(
                  children: [
                    Row(
                      children: [
                        new IconButton(
                          onPressed: (){
                            print("apicheck: $apiCheck");
                            print(ApiUrl.BASE_URL_Test+"users/assessment/1/1");
                            if(apiCheck == ApiUrl.BASE_URL_Test+"users/assessment/1/1") {
                               // Navigator.pop(context);
                              print("store.removeLast" + store.toString());
                              if(store.toString() == [].toString()){
                                print("*******");
                                Navigator.of(context).pop();
                              }
                              print('Previous button hit');
                            }else if(store.toString() == [].toString()){
                              print("######");
                              Navigator.of(context).pop();
                            }else {
                              print('previous btn not hit');
                            }
                            print("storevalue: $store");
                            store.removeLast();
                            lastData.removeLast();
                            removedBrackets = store
                                .toString()
                                .replaceAll("[", "")
                                .replaceAll("]", "");
                            print("removeBrackets" + removedBrackets);
                            // print("store.removelast" + store.removeLast());
                            previous();

                          },
                          icon: new Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                            size: 25.0,
                          ),
                        )
                      ],

                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15),

                    Expanded(
                      child: isLoading ?
                         ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: (arrayValue == null) ? 0 : arrayValue.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: (){
                                  print("checking: ${index.toString()}");
                                  assessmentId = arrayValue[index]['assessment_identifier'];
                                  assessmentIdPrefix =
                                  arrayValue[index]['assessment_identifier'];
                                  print(
                                      "Assessment Prefix Param: ${assessmentIdPrefix}");
                                  secondTimeServerCall('&' + assessmentId);
                                  strArr.add(assessmentId);
                                  finalAssessmentID = json.encode(strArr);
                                  lastData.add(assessmentId);
                                  store.add('&' + assessmentId);
                                  print("finalAssessmentID: ${finalAssessmentID}");

                                  print("strArr : ${strArr}");
                                  print("strArr : ${strArr}");
                                  print("storecheck : ${store}");
                                  print("lastdatacheck: ${lastData}");

                                  checkingvalue = index;
                                  print('Assessment Course' +
                                      checkingvalue.toString());
                                  setState(() {});
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.025,

                                    ),
                                    Card(
                                      color: index == checkingvalue
                                          ? Colors.blueAccent:
                                      Colors.white,
                                      elevation: 10.0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          side: BorderSide(
                                              color: Colors.grey.withOpacity(0.9)
                                          )
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.all(8.0),
                                        width: MediaQuery.of(context).size.width * 0.75,
                                        color: index == checkingvalue
                                            ? Colors.blueAccent
                                            : Colors.white,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
                                              child: Image.asset(
                                                "images/rec.png",
                                                width: 16.0,
                                                height: 16.0,
                                                fit: BoxFit.contain,
                                                color: index == checkingvalue
                                                    ? Colors.white :
                                                Colors.grey[700],
                                              ),
                                            ),
                                            Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Text(
                                                    arrayValue[index]["assessment"],
                                                    style: (checkingvalue == index)
                                                        ? TextStyle(
                                                        color:Colors.white,
                                                        fontSize:16,
                                                        fontWeight: FontWeight.w600

                                                    ):
                                                    TextStyle(
                                                        color:Colors.grey[700],
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600
                                                    ),
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }):
                          Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          )
                    )

                  ]
              )
          ),
        ),
      ),
    );
  }
}
