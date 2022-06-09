import 'dart:convert';

import 'package:fita_app/paymentpage.dart';
import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CourseSchedule extends StatefulWidget {
  String courseFee, enrollmentModeId, branchId;
   CourseSchedule({
     Key? key,
     required this.courseFee,
   required this.enrollmentModeId,
   required this.branchId
   }) :super(key: key);

  @override
  _CourseScheduleState createState() => _CourseScheduleState();
}

class _CourseScheduleState extends State<CourseSchedule> {
  var arrayValue = [];
  var paymentOrderResponse;
  String courseScheduleId = '';
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Course fee: ${this.widget.courseFee}");
    this.widget.courseFee = this.widget.courseFee.replaceAll(",", "");
    print("Course Feees ${this.widget.courseFee}");
    courseSchedule();
  }

  Future<String?> courseSchedule() async {

    final response = await http.post(Uri.parse(
      ApiUrl.BASE_URL_Test + ApiUrl.COURSE_SCHEDULE),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
      },
      body: jsonEncode(<String, String>{
        "couserId" : Preference.getCourseId(Constants.COURSE_ID)
      }));

    if(response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      this.arrayValue = jsonData['data'];
      print("courseSchedule ${this.arrayValue}");
      setState(() {});

    } else {
      throw Exception('Failed to load');
    }

  }

  Future<String?> paymentOrder() async {

    final response = await http.post(Uri.parse(ApiUrl.BASE_URL_Test +
    ApiUrl.PAYMENT_ORDER),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
    },
      body: jsonEncode(<String, String>{
        "couserId": Preference.getCourseId(Constants.COURSE_ID),
        "coursefee": this.widget.courseFee,
      })
    );
    if(response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      this.paymentOrderResponse = jsonData['data'];

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CoursePayment(
            courseFee: this.widget.courseFee,
            orderId: this.paymentOrderResponse['order_id'],
            enrollmentModeId: this.widget.enrollmentModeId,
            scheduleId: courseScheduleId,
            branchId: this.widget.branchId) )
          );
      setState(() {});
    } else {
      throw Exception('Failed to load');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Schedule'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
          iconSize: 25,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/courses_bg.png'),
              fit: BoxFit.cover
            )
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: (arrayValue == null)?0: arrayValue.length,
                    itemBuilder: (BuildContext context,int index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            courseScheduleId = arrayValue[index]['_id'];
                            paymentOrder();
                          });
                        },
                        child: Card(
                          margin: EdgeInsets.all(30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(
                              color: Colors.grey.withOpacity(0.9)
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            width: MediaQuery.of(context).size.width * 0.95,
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: Text(
                                        arrayValue[index]['course_schedule'],
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight:FontWeight.w600
                                        ),
                                      ),
                                    )
                                  ],
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
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
