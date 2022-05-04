import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_app/coursedetailpage.dart';
import 'package:first_app/main.dart';
import 'package:first_app/utils/apiUrl.dart';
import 'package:first_app/utils/constants.dart';
import 'package:first_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;

class ExploureCategoryCourses extends StatefulWidget {
  String receivedCourseId, receivedTitleName;


  @override
  _ExploureCategoryCoursesState createState() => _ExploureCategoryCoursesState();
  ExploureCategoryCourses({Key? key, required this.receivedCourseId,required this.receivedTitleName}) : super(key: key);
}

class _ExploureCategoryCoursesState extends State<ExploureCategoryCourses> {
  var arrayValue;
  Color? colorSelection;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.categoryApiResponse();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<String?> categoryApiResponse() async {
    if(localStore == "exploureFreeCourse") {
      this.colorSelection = Colors.blue;
      final response = await http.get(Uri.parse(ApiUrl.BASE_URL_Test +
      ApiUrl.Exploure_FREE_COURSE_LIST + this.widget.receivedCourseId +
      '/0'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
      },
      );
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data'];
        print("students_enrolled ==> : ${data}");
        setState(() {
          this.arrayValue = data;
        });
      } else {
        throw Exception('Failed to load');
      }
    } else {
      this.colorSelection = Colors.white;
      final response = await http.get(
        Uri.parse(ApiUrl.BASE_URL_Test +
        ApiUrl.Exploure_PAID_COURSE_LIST +
        this.widget.receivedCourseId +
        '/0'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
        },
      );
      if(response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        var data = jsonData['data'];
        print("students_enrolled ==> : ${data}");

        setState(() {
          this.arrayValue = data;
        });
      } else {
        throw Exception('Failed to load');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/courses_bg.png'),
                fit: BoxFit.cover
              )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.10,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/tool_bar_image.png'),
                      fit: BoxFit.cover
                    )
                  ),
                  padding: EdgeInsets.only(top: 30),
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.08,
                        child: new IconButton(onPressed: (){Navigator.pop(context);},
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            )
                        ),
                      ),
                      Text(
                        this.widget.receivedTitleName,
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                          color: Colors.white
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: (arrayValue == null)? 0 : arrayValue.length,
                    padding: EdgeInsets.all(8),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          var courseId = arrayValue[index]['courseId'];
                          Preference.setCourseId(Constants.COURSE_ID, courseId);
                          print(
                              "courseId23 ==> : ${Preference.getCourseId(Constants.COURSE_ID)}");
                          print("courseId ==> : ${courseId}");

                          Navigator.push(context,
                          MaterialPageRoute(builder: (context) =>
                          courseDetailScreen(receivedCourseId: courseId)));
                        },
                        child: Card(
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),

                          ),
                          child: Container(
                            padding: EdgeInsets.all(6),
                            height: MediaQuery.of(context).size.height * 0.13,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: arrayValue[index]['thumbnail_image'],
                                      width: MediaQuery.of(context).size.width * 0.25,
                                      height: MediaQuery.of(context).size.height * 0.20,
                                      fit: BoxFit.fill,
                                      placeholder: (context,url) => Container(),
                                      errorWidget: (context,url,error) => Container(),
                                    ),
                                  ),
                                ),
                                Spacer(
                                  flex: 1,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.01,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: this.colorSelection,
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                          alignment: Alignment.center,
                                          height: 20,
                                          width: 40,
                                          child: Padding(
                                            padding: EdgeInsets.all(2.0),
                                            child: Text(
                                              arrayValue[index]['course_type'],
                                              maxLines: 2,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.005,
                                    ),
                                    Row(
                                      children: [
                                        RatingBar.builder(
                                          initialRating: double.parse(
                                              arrayValue[index]['total_ratings'].toString()),
                                          allowHalfRating: true,
                                          itemSize: 15,
                                          minRating: 5,
                                          itemCount: 5,
                                          direction: Axis.horizontal,
                                          itemBuilder: (context,_) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 10.0,
                                          ), onRatingUpdate: (double value) {  },
                                        )
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          size: 12.0,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          " " + arrayValue[index]['duration'],
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
                                          arrayValue[index]['students_enrolled'].toString()
                                              + " Enrolled ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 11,
                                            fontWeight: FontWeight.normal
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
                                Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [

                                    ],
                                  ),
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
                    },

                  ),
                )
              ],
            ),
          ),
        ));
  }
}
