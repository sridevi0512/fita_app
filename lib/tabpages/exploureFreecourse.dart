import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fita_app/coursedetailpage.dart';
import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/connectivity.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:fita_app/utils/sharedpreferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
String token = "";
class ExploureFreeCourses extends StatefulWidget {
  const ExploureFreeCourses({Key? key}) : super(key: key);

  @override
  _ExploureFreeCoursesState createState() => _ExploureFreeCoursesState();
}

class _ExploureFreeCoursesState extends State<ExploureFreeCourses> {
  TextEditingController searchText = new TextEditingController();
  List arrayValue = [];
  String token = '';
  String titleText = "";
  SharedPreferences? sharedPreferences;
  String staticAPI = '';
  Color? colorSelection;
  String searchAText = '';
  final ScrollController _scrollController = ScrollController();
  int offset = 0;
  bool loading = false,
      allLoaded = false;




  authToken(BuildContext context) async {
    var isNetwork =
    await ConnectivityState.connectivityState.isNetworkAvailable();
    if(isNetwork == true) {
      sharedPreferences = await SharedPreferences.getInstance();
      SharedPreference prefs = SharedPreference();
      Future<String?> authToken = prefs.getAuthToken();
      authToken.then((value) => value.toString());
      authToken.then((value) {
        print("Explr authToken " + value.toString());
        print("Explr authToken 1 " + value!);
      });

      setState(() {
        if(sharedPreferences!.getString("token") != null){
          token = sharedPreferences!.getString("token")!;
          print("Explr Token 1" + token.toString());
        }

      });
      this.exploreFreeCourseApiResponse();
      this.searchText.addListener(_handleText);
      return authToken;

    } else {
      ConnectivityState.showCustomDialog(context,
          title: 'Please make sure you are connected to internet and try again',
          okBtnText: 'Okay');
    }

  }


  void initState() {
    super.initState();
    authToken(context);
    if(localStore == "exploureFreeCourse") {
      titleText =  "Free Courses";
    } else {
      titleText = "Courses";
    }
  }
  pagination() async {
    if(_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        offset += 1;
        this.exploreFreeCourseApiResponse();
      });
      print('Pagination offset: ${offset.toString()}');
      print("Pagination sp: ${_scrollController.position.pixels.toString()}");
    } else {
      print("Pagination offset else : ${offset.toString()}");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
    this.searchText.dispose();
  }
  _handleText() {
    searchAText = this.searchText.text;
    // this.exploreFreeCourseApiResponse();
    this.trendingFreeCourseApiResponse();

    print(searchAText);
  }

  Future<String?> trendingFreeCourseApiResponse() async{
    print('Free search Course  called');
    print('offset ' + offset.toString());
    if (localStore == "exploureFreeCourse") {
      colorSelection = Colors.blue;


      print(
          "Api ==> : ${ApiUrl.BASE_URL_Test+'course/trending-free-courses?offset=0&search=' +
              searchAText}");

      final response = await http.get(Uri.parse(
          ApiUrl.BASE_URL_Test+'course/trending-free-courses?offset=0&search=' +
              searchAText),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
        },
      );
      if (response.statusCode == 200) {

        var jsonData = jsonDecode(response.body);
        print("searchText ==> : ${searchText.text}");
        var data = jsonData['data'];
        print("students_enrolled ==> : ${data}");

        setState(() {
          this.arrayValue = data;
        });
      } else {

        Fluttertoast.showToast(msg: "No data found",toastLength: Toast.LENGTH_SHORT,gravity: ToastGravity.BOTTOM);
        throw Exception('Failed to load');
      }
    } else {

      colorSelection = Colors.white;
      print(
          "Api ==> : ${ApiUrl.BASE_URL_Test+'course/trending-paid-courses?offset=0&search=' + searchAText}");
      final response = await http.get(Uri.parse(
          ApiUrl.BASE_URL_Test+'course/trending-paid-courses?offset=0&search=' +
              searchAText),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print("searchText ==> : ${searchText.text}");
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

  Future<String?> exploreFreeCourseApiResponse() async {
    print('Free Course Api called');
    print('offset ' + offset.toString());

    if(localStore == "exploureFreeCourse") {
      colorSelection = Colors.blue;
      staticAPI = ApiUrl.BASE_URL_Test+'course/free-courses/0';
    } else {
      colorSelection = Colors.white;
      staticAPI = ApiUrl.BASE_URL_Test+'course/paid-courses/0';
      print("Api ${staticAPI}");
    }
    final response = await http.get(Uri.parse(staticAPI),
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
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'images/courses_bg.png'
                  ),
                  fit: BoxFit.cover,
                )
            ),
            child: Column(
              children: [
                Container(
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
                        child: new IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            icon: new Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            )
                        ),
                      ),
                      Text(
                        titleText,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w500
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10,left: 10),
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: TextField(
                    controller: searchText,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Search',
                        contentPadding: EdgeInsets.symmetric(horizontal: 32.0,vertical: 14.0),
                        suffixIcon: Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(75.0),
                            borderSide: BorderSide.none
                        ),
                        labelStyle: TextStyle(
                            fontSize: 24,
                            color: Colors.black
                        )
                    ),
                  ),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 75,
                            offset: const Offset(0, 0)
                        )
                      ]
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
                          print("course123 ==> ${Preference.getCourseId(Constants.COURSE_ID)}");

                          setState(() {});
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => courseDetailScreen(
                                receivedCourseId: courseId,
                              )));

                        },
                        child: Card(
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)
                          ),
                          child: Container(
                            padding: EdgeInsets.all(6),
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
                                        width: MediaQuery.of(context).size.width * 0.25,
                                        height: MediaQuery.of(context).size.height * 0.20,
                                        fit: BoxFit.cover,
                                        placeholder: (context,url) => Image.asset('images/no_image.png'),
                                        errorWidget: (context,url,error) => Image.asset('images/no_image.png'),

                                      ),
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
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: colorSelection,
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
                                                  backgroundColor: colorSelection,
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.005,
                                    ),
                                    Row(
                                      children: [
                                        RatingBar.builder(
                                          minRating: 5,
                                          itemSize: 15.0,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          initialRating: double.parse(arrayValue[index]['total_ratings'].toString()),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 10.0,
                                          ),
                                          onRatingUpdate: (double value) {  },
                                        )
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          size: 12,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          " " +
                                              arrayValue[index]['duration'].toString(),
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 11
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width *0.10,
                                        ),
                                        Text(
                                          arrayValue[index]['students_enrolled'].toString()
                                              + " Enrolled ",
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black
                                          ),
                                          textAlign: TextAlign.left,
                                        )
                                      ],
                                    ),


                                  ],
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.005 ),
                                Padding(padding: EdgeInsets.only(top: 3),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [],
                                  ),
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.005 ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                    color: Colors.black,
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
            )
        ),
      ),
    );

  }
}
