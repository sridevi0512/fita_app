import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'coursedetailpage.dart';

class AssessmentCourse extends StatefulWidget {
  String receivedJsonData, token;


  @override
  _AssessmentCourseState createState() => _AssessmentCourseState();
   AssessmentCourse({Key? key,
     required this.receivedJsonData,
     required this.token})
       : super(key: key);
}

class _AssessmentCourseState extends State<AssessmentCourse> {
  var arrayValue;
  int checkingvalue = -1;
  var statuscode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    assessmentCourseApi();
  }

  Future<String?> assessmentCourseApi() async {
    final response = await http.post(
      Uri.parse(ApiUrl.BASE_URL_Test+'users/assessment-course'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
      },
      body: widget.receivedJsonData,
    );

    if(response.statusCode == 200) {
      print('inside assessment course');
      var jsonData = jsonDecode(response.body);
      print("assessmentCourseApi: ${jsonData}");
      var data = jsonData['data'];
      print('assessmentValues=> ${data}');

      setState(() {
        arrayValue = data;

      });
    } else {
       Navigator.pop(context);
      var jsonData1 = jsonDecode(response.body);
      print('else assessment course');
      Fluttertoast.showToast(msg: jsonData1['status']['message'],
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM);
      print('jsonData1: ${jsonData1['status']['message']}');

      Text(
        jsonData1['status']['message'],
        style: TextStyle(fontWeight: FontWeight.bold,
        fontSize: 16),
      );
    }

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Image(
            image: AssetImage("images/tool_bar_image.png"),
            fit: BoxFit.cover,
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading:                             Row(
            children: [
              IconButton(
                icon: new Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 25,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        ),
        body: Container(
          /*decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/fita_app_background_xxhdpi_3x.png'),
              fit: BoxFit.cover,
            )
          ),*/
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                 Text(
                'Your eligible courses\nbased on your assessment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                      itemCount: (arrayValue == null) ?0 : arrayValue.length,
                      itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: (){
                          var courseId = arrayValue[index]['courseId'];
                          print("courseId: ==> ${courseId}");

                          setState(() {});
                            Navigator.push(
                              context,
                                MaterialPageRoute(
                                    builder: (context) => courseDetailScreen(
                                      receivedCourseId:courseId
                                    )));

                        },
                        child: Card(
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(6),

                            height: MediaQuery.of(context).size.height * 0.13,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [

                                Expanded(
                                  flex: 10,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: arrayValue[index]['thumbnail_image'],
                                        width:  MediaQuery.of(context).size.width * 0.25,
                                        height: MediaQuery.of(context).size.height * 0.25,
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) => Image.asset('images/no_image.png'),
                                        errorWidget: (context, url, error) => Image.asset('images/no_image.png'),
                                      )

                                    )
                                ),
                                Spacer(
                                  flex: 1,
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.40,
                                          child: Text(
                                            arrayValue[index]['course'],
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize:12,
                                              fontWeight:FontWeight.w600
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.01,
                                        ),
                                        arrayValue[index]['course_type'] =='free' ?
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.circular(10)
                                              ),
                                              alignment: Alignment.center,
                                              height: 20,
                                              width: 40,
                                              child: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: Text(
                                                  arrayValue[index]['course_type'],
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    backgroundColor: Colors.blue,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.normal
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            )
                                            :
                                            Container(),
                                      ],
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.005,
                                    ),
                                    Row(
                                      children: [
                                        RatingBar.builder(
                                          initialRating: double.parse(
                                            arrayValue[index]['total_ratings'].toString()
                                          ),
                                            minRating: 5,
                                            itemCount: 5,
                                            itemSize: 15.0,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 10.0,
                                            ), onRatingUpdate: (double value) {  },
                                            )
                                      ],
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.005,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          color: Colors.black,
                                          size: 12.0,
                                        ),
                                        Text(
                                          " " +
                                            arrayValue[index]['duration'].toString(),
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 11,
                                            fontWeight: FontWeight.normal
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.10,
                                        ),
                                        Text(
                                          arrayValue[index]['students_enrolled'].toString() + " " +
                                            'Enrolled',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 11,
                                            fontWeight:FontWeight.normal
                                          ),
                                          textAlign: TextAlign.left,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.005,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black,
                                    size: 15.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                      }))
            ],
          ),
        ),
      ),
    );
  }
}
