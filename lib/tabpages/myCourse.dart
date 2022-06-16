import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../utils/apiurl.dart';

class MyCourse extends StatefulWidget {
  const MyCourse({Key? key}) : super(key: key);

  @override
  _MyCourseState createState() => _MyCourseState();
}

class _MyCourseState extends State<MyCourse> {

  var myCourseList = [];
  String isEmptyList = "null";

  Future<String?> getMyCourseList() async{
    print(ApiUrl.BASE_COURSE_URL + ApiUrl.MY_COURSE);

    final response = await http.get(
      Uri.parse(ApiUrl.BASE_COURSE_URL + ApiUrl.MY_COURSE),
      headers: <String,String> {
        'Content-Type': 'application/json',
        'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
      }
    );
    try{
      if(response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['mycoursedata'];
        print("MyCourse data ==> ${data.toString()}");
        setState(() {
          myCourseList = data;
          if(data.isEmpty){
            showAlertDialog(context);
          } else {
            isEmptyList = "";
          }
        });
      } else {
        var jsonData1 = jsonDecode(response.body);
        Fluttertoast.showToast(msg: jsonData1['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
        Navigator.pop(context);
      }
    } catch (Exception) {
      print('Exception: ${Exception.toString()}');
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyCourseList();
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
        onPressed: (){
          Navigator.of(context, rootNavigator: true).pop('dialog');
        },
        child: Text("Okay")
    );
    AlertDialog alert = AlertDialog(
      content: Text("No data found"),
      actions: [
        okButton
      ],
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Course'),
        automaticallyImplyLeading: false,
      ),
      body:
      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "My Courses",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: "Montserrat"
                  ),
                ),
              ),
              ListView.separated(
                itemCount: myCourseList.length,
                shrinkWrap: true,
                separatorBuilder: (context,index) {
                  return Divider(
                    height: 5,
                  );
                },
                physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index){
                  return Container(
                    child: Card(
                      elevation: 2.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              child: CachedNetworkImage(
                                imageUrl: myCourseList[index]['thumbnailimage'],
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height/4,
                                fit: BoxFit.fill,

                                placeholder: (context,url) => Image.asset("images/placeholder_image.jpg",
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height/4,
                                  fit: BoxFit.fill,),

                                errorWidget: (context,url,error) => Image.asset("images/placeholder_image.jpg",
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height/4,
                                fit: BoxFit.fill),
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (myCourseList[index]['course'].toString().length <= 20)?
                                  MergeSemantics(
                                    child: Row(
                                      children: [
                                        Text(
                                          "Course Name: ",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Montserrat"
                                          ),
                                        ),
                                        SizedBox(width: 5, height: 5),
                                        Flexible(
                                          child:Text(
                                            myCourseList[index]['course'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Montserrat"
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ):
                                  MergeSemantics(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Course Name: ",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Montserrat"
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Flexible(
                                          child:Text(
                                            myCourseList[index]['course'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Montserrat"
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  MergeSemantics(
                                    child: Row(
                                      children: [
                                        Text(
                                          "Course Schedule: ",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Montserrat"
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Flexible(
                                          child:Text(
                                            myCourseList[index]['courseSchedule'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Montserrat"
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  (myCourseList[index]['branch'].toString() == "")?
                                      Container():
                                  MergeSemantics(
                                    child: Row(
                                      children: [
                                        Text(
                                          "Branch: ",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Montserrat"
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Flexible(
                                          child:Text(
                                            myCourseList[index]['branch'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Montserrat"
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  (myCourseList[index]['status'].toString().length <= 4)?
                                  MergeSemantics(
                                    child: Row(
                                      children: [
                                        Text(
                                          "Student Course Status: ",
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Montserrat"
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Flexible(
                                          child:Text(
                                              myCourseList[index]['status'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Montserrat"
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ):
                                  MergeSemantics(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Student Course Status: ",
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Montserrat"
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Flexible(
                                          child:Text(
                                            myCourseList[index]['status'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Montserrat"
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  (myCourseList[index]['coursefeetype'].toString() == 'Classroom')?
                                  MergeSemantics(
                                    child: Row(
                                      children: [
                                        Text(
                                          "Course Feestype: ",
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Montserrat"
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Flexible(
                                          child:Text(
                                            myCourseList[index]['coursefeetype'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Montserrat"
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ):
                                  MergeSemantics(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Course Feestype: ",
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Montserrat"
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Flexible(
                                          child:Text(
                                            myCourseList[index]['coursefeetype'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Montserrat"
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  (myCourseList[index]['created_at'].toString().length <=10) ?
                                  MergeSemantics(
                                    child: Row(
                                      children: [
                                        Text(
                                          "Course Register Date: ",
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Montserrat"
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Flexible(
                                          child:Text(
                                            myCourseList[index]['created_at'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Montserrat"
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ):
                                  MergeSemantics(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Course Register Date: ",
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Montserrat"
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Flexible(
                                          child:Text(
                                            myCourseList[index]['created_at'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Montserrat"
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            )
                          ],
                        ),
                    ),
                  );
                },
              )
            ],
          )
        ),
      ),

    );
  }
}
