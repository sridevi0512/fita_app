import 'dart:convert';

import 'package:fita_app/paymentpage.dart';
import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart ' as http;

import 'courseschedule.dart';

class CoursePaidPaymentScreen extends StatefulWidget {
  String receivedCourseId;


  @override
  _CoursePaidPaymentScreenState createState() => _CoursePaidPaymentScreenState();
  CoursePaidPaymentScreen({Key? key, required this.receivedCourseId}) : super(key: key);
}


class _CoursePaidPaymentScreenState extends State<CoursePaidPaymentScreen> {
  String _dropDownValue = "";
  String courseFee ="", enrollmentModeId = "";
  var currentSelectedValue;
  bool _visible = false;
  bool classroomKey = false;
  List<String> _locations = [
    "Anna nagar",
    "Tambaram",
    "Velachery",
    "T Nagar",
    "OMR",
    "Saravanampatti"
  ];

  String _selectedLocation = "Please choose a location";

  List<String> iconImages = [
    "images/self_paced_icon.png",
    "images/instructure_order_online.png",
    "images/class_room.png"
  ];

  var arrayValue = [];
  var paymentOrderResponse;
  int _value = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("always cal1");
    enrollForPaid();
  }

  Future<String?> enrollForPaid() async {
    print("always cal2");

    final response = await http.get(Uri.parse(
      ApiUrl.BASE_URL_Test + ApiUrl.Enroll_PAID_type
          + Preference.getCourseId(Constants.COURSE_ID)
    ),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
      },
    );
    
    if(response.statusCode == 200) {
      print("always cal3");
      var jsonData = jsonDecode(response.body);
      this.arrayValue =jsonData['data'];
      setState(() {});
    } else {
      print("always cal4");
      throw Exception('Failed to load');
    }
  }
  
  Future<String?> paymentOrder() async {
    
    final response = await http.post(Uri.parse(ApiUrl.BASE_URL_Test + ApiUrl.PAYMENT_ORDER),
      headers:<String, String>{
        'Content-Type': 'application/json',
        'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
      },
        body: jsonEncode(<String, String>{
          "couserId": Preference.getCourseId(Constants.COURSE_ID),
          "coursefee": this.courseFee,
        })
    );
    if(response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      this.paymentOrderResponse = jsonData['data'];
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => CoursePayment(
            courseFee : this.courseFee,
            orderId : this.paymentOrderResponse['order_id'],
            enrollmentModeId : this.enrollmentModeId,
            scheduleId : null,
            branchId: null,
          )),
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
        title: Text('Enroll Course'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
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
              fit: BoxFit.cover,
            )
          ),
          child: Column(
            children: [
              Expanded(
                  child: Center(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      itemCount: (arrayValue == null) ? 0 : arrayValue.length,
                      itemBuilder: (BuildContext context, int index) {
                        arrayValue[index]['coursefee'] == '0' ? _visible = false
                            : _visible = true;
                        arrayValue[index]['enroll_type'] == 'Classroom'
                        ? classroomKey = true
                            : classroomKey = false;
                        print(classroomKey);

                        return Visibility(
                          visible: _visible,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {

                                if(arrayValue[index]['enroll_type_name'] ==
                                'self_paced') {
                                  enrollmentModeId =
                                      arrayValue[index]['course_fee_id'];
                                  courseFee = arrayValue[index]['discountcoursefee'].toString()
                                  .replaceAll(",", "");
                                  paymentOrder();
                                } else {
                                  if(arrayValue[index]['enroll_type_name'] ==
                                  "classroom") {
                                    print('Classroom');
                                    if(currentSelectedValue != null) {
                                      print('BRANCH: ' + currentSelectedValue);

                                      Navigator.push(context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                          CourseSchedule(
                                            courseFee : arrayValue[index]
                                                ['discountcoursefee'],
                                            enrollmentModeId: arrayValue[index]
                                              ['course_fee_id'],
                                            branchId: currentSelectedValue
                                          ))
                                      );
                                    } else {
                                      Fluttertoast.showToast(msg: 'Please select branch',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM);
                                      print("BRANCH: Please select  branch");
                                    }
                                  } else {
                                    print("Instructor");
                                    currentSelectedValue = null;
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) =>
                                        CourseSchedule(courseFee: arrayValue[index]['discountcoursefee'],
                                            enrollmentModeId: arrayValue[index]['course_fee_id'],
                                            branchId: currentSelectedValue))
                                    );
                                  }
                                }
                              });
                            },
                            child: Card(
                              margin: EdgeInsets.only(
                                top: 10.0,
                                left: 5.0,
                                right: 5.0,
                                bottom: 30.0
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(
                                  color: Colors.grey.withOpacity(0.9)
                                )
                              ),
                              child: Container(
                                margin: EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * 0.95,
                                height: MediaQuery.of(context).size.height * 0.1,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(30.0, 20.0, 10.0, 20.0),
                                      child: Image.asset(iconImages[index],
                                      width: 20.0,
                                          height: 30.0,
                                          fit: BoxFit.cover
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                          .size.width * 0.30,
                                          child: Text(
                                            arrayValue[index]['enroll_type'],
                                            maxLines: 2,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: classroomKey,
                                          child: Row(
                                            children: [
                                              DropdownButton<String>(
                                                hint: Text('Select the Branch'),
                                                  value: currentSelectedValue,
                                                  isDense: true,
                                                  items: _locations.map((String value) {
                                                    return new DropdownMenuItem(
                                                        child: new Text(value),
                                                    value: value,
                                                    );
                                                  }).toList(),
                                                  onChanged: (newValue) {
                                                  setState(() {
                                                    currentSelectedValue =
                                                        newValue;
                                                  });
                                                  print(currentSelectedValue);
                                                  },
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 11,
                                                fontWeight: FontWeight.normal
                                              ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Spacer(),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "\₹ " +
                                                arrayValue[index]
                                                  ['discountcoursefee'] +
                                                "/",
                                              style: TextStyle(
                                                color: Colors.blueAccent[700],
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "\₹ " +
                                                arrayValue[index]
                                                  ['coursefee'] + "/",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                decoration: TextDecoration.lineThrough,
                                                decorationColor: Colors.red,
                                                decorationThickness: 2.85,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    Spacer(),
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
                              )
                            )
                          ),
                        );
                      },
                    ),
                  ) )
            ],
          ),
        ),
      ),
    );
  }
}
