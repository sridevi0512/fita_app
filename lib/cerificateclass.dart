import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fita_app/coursedetailpage.dart';
import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/connectivity.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:fita_app/utils/sharedpreferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class CertificationClass extends StatefulWidget {
  String imageURL;


  @override
  _CertificationClassState createState() => _CertificationClassState();
  CertificationClass({Key? key,
    required this.imageURL})
      : super(key: key);
}

class _CertificationClassState extends State<CertificationClass> {
  var arrayValue;
  String token = '';
  String titleText = "";
  SharedPreferences? sharedPreferences;
  String staticAPI = "";
  String certificateLastUrl = '';
  String insideImgURL = '';

  authToken(BuildContext context) async {
    var isNetwork = await ConnectivityState.connectivityState.isNetworkAvailable();
    if(isNetwork == true) {
      sharedPreferences = await SharedPreferences.getInstance();
      SharedPreference prefs = SharedPreference();
      Future<String?> authToken = prefs.getAuthToken();
      authToken.then((value) => value.toString());
      authToken.then((value) {
        print("Explore authToken" + value.toString());
        print("Explore authToken1" + value!);
      });

      setState(() {
        if(sharedPreferences!.getString("token") != null) {
          token = sharedPreferences!.getString("token")!;
          print("Explore Tokennnn 1" + token.toString());
        }
      });
      try{
        this.exploreFreeCourseApiResponse();
        print('try');
      } catch (Exception) {
        print("catch");
      }
      return authToken;

    } else {
      ConnectivityState.showCustomDialog(context,
          title: 'Please make sure you are connected to internet and try again',
          okBtnText: 'Okay');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authToken(context);
  }

  Future<String?> exploreFreeCourseApiResponse() async {
    print("certificate_Url: ${ApiUrl.BASE_URL_Test +
        ApiUrl.CERTIFICATE +
        Preference.getCourseId(Constants.COURSE_ID) +
        '/' +
        Preference.getUserId(Constants.USER_ID)}");
    print(ApiUrl.BASE_URL_Test +
        ApiUrl.CERTIFICATE +
        Preference.getCourseId(Constants.COURSE_ID) +
        '/' +
        Preference.getUserId(Constants.USER_ID));

    final response = await http.get(Uri.parse(
        ApiUrl.BASE_URL_Test +
            ApiUrl.CERTIFICATE +
            Preference.getCourseId(Constants.COURSE_ID) +
            '/' +
            Preference.getUserId(Constants.USER_ID)
    ),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
      },
    );
    print('COURSE ID ${Preference.getCourseId(Constants.COURSE_ID)}');
    print('USER ID ${Preference.getUserId(Constants.USER_ID)}');
    print('GET TOKEN ${Preference.getAuthToken(Constants.AUTH_TOKEN)}');

    if(response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data']['assessmentCouresesData'];
      print('students_enrolled ==> ${data}');
      var cert = jsonData['data']['certificate'];
      this.insideImgURL = cert;

      print('Base Url ${ApiUrl.BASE_CERTIFICATION_URL}');
      print('URL ${jsonData['data']['certificate']}');
      setState(() {
        this.arrayValue = data;
      });
      print('No catch error');
    } else {
      print('catch error');
      throw Exception('Failed to load');
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/courses_bg.png'),
              fit: BoxFit.cover,
            ),
          ),


          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  new IconButton(
                    icon: new Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 30.0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                // width: 350,
                // height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                    child:
                    Padding(padding: EdgeInsets.all(5),
                    child:
                    Text(
                        "Congratulations on Completing",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center),
                    )
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                // width: 280,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                        Preference.getCourseName(Constants.COURSE_NAME),
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 23,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl:
                    this.insideImgURL == null
                        ? widget.imageURL
                        : this.insideImgURL,
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.25,
                    fit: BoxFit.fill,
                    placeholder: (context,url) => Container(),
                    errorWidget: (context,url,error) =>Container(),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                // width: 300,
                // height: 50,

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "Your Certificate of Excellence is available in My Certificate Section",
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(5),
                width: MediaQuery.of(context).size.width * 0.95,
                // height: 80,
                color: Color(0xFF0D47A1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.65,

                      child: Text(
                          "Take up Classroom or Live Instructor-lead Training & Get your Dream Job!",
                          maxLines: 3,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Container(
                child: Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: (arrayValue == null) ? 0 : arrayValue.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            localStore = 'explourePaidCourse';
                            var courseId = arrayValue[index]['courseId'];
                            print("courseId ==> : ${courseId}");
                            setState(() {});
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => courseDetailScreen(
                                        receivedCourseId: courseId)));
                          },
                          child: Card(
                            elevation: 10.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              height: MediaQuery.of(context).size.height * 0.13,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    flex: 10,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                        arrayValue[index]['thumbnail_image'],
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.25,
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.20,
                                        fit: BoxFit.fill,
                                        placeholder: (context,url) => Container(),
                                        errorWidget: (context,url,error) => Container(),
                                      ),
                                    ),
                                  ),
                                  //Spacer(),

                                  Spacer(
                                    flex: 1,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    //mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width *
                                                0.40,


                                            child: Text(
                                              arrayValue[index]['course'],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.01),
                                          Container(
                                            decoration: new BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                BorderRadius.circular(10)),
                                            alignment: Alignment.center,
                                            height: 20,
                                            width: 40,
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(2.0),
                                              child: Text(
                                                  arrayValue[index]
                                                  ['course_type'],
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      backgroundColor:
                                                      Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                      FontWeight.w600),
                                                  textAlign: TextAlign.center),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.005,
                                      ),
                                      Row(
                                        children: [
                                          RatingBar.builder(
                                            initialRating: double.parse(
                                                arrayValue[index]
                                                ['total_ratings']
                                                    .toString()),
                                            minRating: 5,
                                            itemSize: 15.0,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 10.0,
                                            ), onRatingUpdate: (double value) {  },
                                          ),

                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.005,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.timer,
                                            color: Colors.black,
                                            size: 12.0,
                                          ),
                                          Text(
                                            " " +
                                                arrayValue[index]['duration']
                                                    .toString(),
                                            maxLines: 2,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 11,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width *
                                                0.10,
                                          ),
                                          Text(
                                              arrayValue[index]
                                              ['students_enrolled']
                                                  .toString() +
                                                  ' Enrolled',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                  fontWeight:
                                                  FontWeight.normal),
                                              textAlign: TextAlign.left),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.005,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.005,
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
                      }),
                ),
              ),
            ],
          ),
        ),

      ),
    );

  }
}
