
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fita_app/tabpages/exploureFreecourse.dart';
import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/connectivity.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:fita_app/utils/sharedpreferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../coursedetailpage.dart';
import '../explourecategorypage.dart';
import '../loginmainpage.dart';
import '../main.dart';


class Course extends StatefulWidget {
  @override
  _CourseState createState() => _CourseState();
}

class _CourseState extends State<Course> {
  TextEditingController searchText = new TextEditingController(text: "");

  var arrayValue;
  var exploreArrayValue;
  String trendingTile = "";
  String explloureTitle = "";
  String searchAText = "";
  String? token;
  SharedPreferences? sharedPreferences;
  Color? colorSelection;

  authToken(BuildContext context) async {
    var isNetwork =
    await ConnectivityState.connectivityState.isNetworkAvailable();
    if (isNetwork == true) {
      sharedPreferences = await SharedPreferences.getInstance();
      SharedPreference prefs = SharedPreference();
      Future<String?> authToken = prefs.getAuthToken();
      authToken.then((value) => value.toString());
      authToken.then((value) {
        //token = value.toString();
        print("authToken " + value.toString());
        print("authToken 1 " + value!);
      });

      setState(() {
        if(sharedPreferences!.getString("token") != null){
          token = sharedPreferences!.getString("token");
          print('Tokenn 1' + token.toString());
        }

      });
      this.trendingFreeCourseApiResponse();
      this.exploreFreeCourseApiResponse();
      this.searchText.addListener(_handleText);
      return authToken;
    } else {
      ConnectivityState.showCustomDialog(
        context,
        title: 'Please make sure you are connected to internet and try again',
        okBtnText: 'Okay',
      );
    }
  }

  void initState()  {
    super.initState();
    authToken(context);
  }

  @override
  void dispose() {

    this.searchText.dispose();
    super.dispose();
  }

  _handleText() {

    searchAText = this.searchText.text;
    this.trendingFreeCourseApiResponse();
    print(searchAText);
  }



  Future<String?> trendingFreeCourseApiResponse() async {

    if (localStore == "exploureFreeCourse") {
      trendingTile = "Trending Free Courses";
      colorSelection = Colors.blue;

      print(
          "Api ==> : ${ApiUrl.BASE_URL_Test+'course/trending-free-courses?offset=0&search=' + searchAText}");
      final response = await http.get(Uri.parse(
          ApiUrl.BASE_URL_Test+'/course/trending-free-courses?offset=0&search=' +
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
        var jsonData1 = jsonDecode(response.body);
        print('RESPONSE: ' + jsonData1.toString());
        print("Error ${jsonData1['status']['message']}");
        (jsonData1['status']['message'] == "Already you have logged on another device!")?showAlertDialog(context, jsonData1['status']['message']):
        showAlertDialog(context, "");

      }
    } else {
      trendingTile = "Trending Courses";
      colorSelection = Colors.white;
      print(
          "Api ==> : ${ApiUrl.BASE_URL_Test+'course/trending-paid-courses?offset=0&search=' + searchAText}");
      final response = await http.get(Uri.parse(
          ApiUrl.BASE_URL_Test+'/course/trending-paid-courses?offset=0&search=' +
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
        var jsonData1 = jsonDecode(response.body);
        print('RESPONSE: ' + jsonData1.toString());
        print("Message1" + jsonData1['status']['message']);
        showAlertDialog(context, jsonData1['status']['message']/*""*/);

      }
    }
  }


  Future<String?> exploreFreeCourseApiResponse() async {

    if (localStore == "exploureFreeCourse") {
      this.explloureTitle = "Explore all Free Courses";
      final response = await http.get(Uri.parse(
          ApiUrl.BASE_URL_Test + ApiUrl.Exploure_FREE_COURSE + '0'),
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
          this.exploreArrayValue = data;
        });
      } else {

        throw Exception('Failed to load');
      }
    } else {
      this.explloureTitle = "Explore all Courses";

      final response = await http.get(Uri.parse(
          ApiUrl.BASE_URL_Test + ApiUrl.Exploure_PAID_COURSE + '0'),
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
          this.exploreArrayValue = data;
        });
      } else {
        print(Exception);
        throw Exception('Failed to load');
      }
    }

  }

  showAlertDialog(BuildContext context, String message) {
    Widget okButton = TextButton(
      child: Text("Ok"),
      onPressed: () {
        if(mounted) {
          setState(() {
            logoutApi();
            Navigator.of(context, rootNavigator: true).pop('dialog');
            Navigator.pop(context);
          });
        }
      },
    );


    AlertDialog alert = AlertDialog(
      title: Text("Session expired/Something went wrong"),
      content: Text(message + "\nLogging out.."),
      actions: [
        okButton,
      ],
    );


    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<String?> logoutApi() async {
    // showLoaderDialog(context);
    print("logout");
    var response;
    response = await http.post(Uri.parse(ApiUrl.BASE_URL + ApiUrl.LOGOUT),
        headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN)
    });
    try {
      Navigator.pop(context);
      var data = json.decode(response.body);
      print('Logout Try');
      Fluttertoast.showToast(msg:data['status']['message'],
          toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      if (response == 200) {
        print('Logout 200');
        print('If');
      } else if (response == 400) {
        print('Logout 400');
        var data1 = json.decode(response.body);
        Fluttertoast.showToast(msg:data1['status']['message'],
            toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
        print('Else' + data1['status']);
      }

      if (data['status']['status'] == "Success") {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) {
              return LoginMainPage();
            },
            transitionsBuilder: (context, animation1, animation2, child) {
              return FadeTransition(
                opacity: animation1,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 1),
          ),
        );
        Preference.setAuthToken(Constants.AUTH_TOKEN, "");
        Fluttertoast.showToast(msg:data['status']['message'],
            toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) {
              return LoginMainPage();
            },
            transitionsBuilder: (context, animation1, animation2, child) {
              return FadeTransition(
                opacity: animation1,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 1),
          ),
        );
        Preference.setAuthToken(Constants.AUTH_TOKEN, "");
        Fluttertoast.showToast(msg:"Logged out successfully",
            toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
      }
    } catch (Exception) {
      print('Logout Catch');
      if(mounted) {
        Navigator.pop(context);
      }
      Fluttertoast.showToast(msg:
      'The server is temporarily unable to service your request',
          toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Positioned.fill(
                    child: Image(
                      image: AssetImage('images/courses_bg.png'),
                      fit: BoxFit.cover,
                    )
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10,top: 10),
                        width: MediaQuery.of(context).size.width * 0.95,
                        child: TextField(
                          controller: searchText,
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              hintText: 'Search',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 32.0,vertical: 14.0
                              ),
                              suffixIcon: Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(75.0),
                                  borderSide: BorderSide.none
                              ),
                              labelStyle: TextStyle(fontSize: 24,color: Colors.black)
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
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.060,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        margin: EdgeInsets.only(left: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 5),

                            ),
                            Container(
                              child: Text(
                                this.trendingTile,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(height: 14),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.29,
                              margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (arrayValue == null)? 0: arrayValue.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: (){
                                      var courseId = arrayValue[index]['courseId'];
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => courseDetailScreen(
                                              receivedCourseId: courseId
                                          )));
                                      setState(() {});
                                    },
                                    child: Container(
                                      height: 220,
                                      width: 220,
                                      child: Card(
                                        elevation: 3.0,
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0)
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 0.0,
                                            ),
                                            Flexible(
                                              child:ClipRRect(
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)),
                                                child: CachedNetworkImage(
                                                  imageUrl: arrayValue[index]['thumbnail_image'],
                                                  width: MediaQuery.of(context).size.width * 0.95,
                                                  height: MediaQuery.of(context).size.height * 0.15,
                                                  fit: BoxFit.cover,
                                                  placeholder:(context,url) => Image.asset('images/no_image.png'),
                                                  errorWidget: (context,url,error) => Image.asset('images/no_image.png'),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8.0,
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 8.0, right: 8.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    decoration: new BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        color: colorSelection
                                                    ),
                                                    alignment: Alignment.center,
                                                    height: 20,
                                                    width: 40,
                                                    child: Text(
                                                      arrayValue[index]['course_type'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          backgroundColor: colorSelection,
                                                          fontWeight: FontWeight.w600

                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Icon(
                                                    Icons.timer,
                                                    color: Colors.black,
                                                    size: 15,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    arrayValue[index]['duration'],
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize:12
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 6.0),
                                            Container(
                                              margin: EdgeInsets.only(left: 8,right: 8),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    arrayValue[index]['course'],
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 13
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:EdgeInsets.only(left:5,right:5),
                                                  child: RatingBar.builder(
                                                    initialRating: double.parse(arrayValue[index]['star_ratings'].toString()),
                                                    allowHalfRating: true,
                                                    itemSize: 15,
                                                    minRating: 5,
                                                    direction: Axis.horizontal,
                                                    itemBuilder: (context,_)=> Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 10.0,
                                                    ), onRatingUpdate: (double value) {  },
                                                  ),
                                                ),
                                                Spacer(),
                                                Padding(
                                                  padding: EdgeInsets.only(left: 5,right: 5),
                                                  child: Text(
                                                    (arrayValue[index]['students_enrolled']== null)? ""
                                                        : arrayValue[index]['students_enrolled'].toString() + " Enrolled ",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 12
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Align(
                                alignment: Alignment.topRight,
                                child:Container(
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    gradient: new LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 254, 97, 44),
                                        Color.fromARGB(255, 241, 29, 40)
                                      ],


                                    ),
                                    borderRadius: BorderRadius.circular(5.0),

                                  ),
                                  alignment: Alignment.center,
                                  height: 20,
                                  width: 90,
                                  child: GestureDetector(
                                    onTap: (){
                                      setState(() {});
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ExploureFreeCourses()));
                                    },
                                    child: Text(
                                      "View More",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.025,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 12),
                              width: MediaQuery.of(context).size.width * 0.95,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    this.explloureTitle,
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 19
                                    ),
                                    textAlign: TextAlign.left,

                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.03,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 30,right: 30),
                                    child: GridView.count(
                                        crossAxisCount: 2,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        childAspectRatio: 1.0,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 30,
                                        children: List.generate((exploreArrayValue == null)? 0 : exploreArrayValue.length,
                                                (index){
                                              return GestureDetector(
                                                onTap: () {
                                                  var courseId =exploreArrayValue[index]['category_id'];
                                                  print("courseId ==> ${courseId}");
                                                  var categoryName = exploreArrayValue[index]['category'];
                                                  print("category_name ==> ${categoryName}");
                                                  setState(() {});
                                                  Navigator.push(context,
                                                      MaterialPageRoute(builder: (context) => ExploureCategoryCourses(
                                                          receivedCourseId : courseId,
                                                          receivedTitleName : categoryName
                                                      )));
                                                },
                                                child: Container(
                                                  height: 90,
                                                  width: 100,
                                                  child: Card(
                                                    elevation: 3.0,
                                                    color: Colors.white,
                                                    margin: EdgeInsets.all(5.0),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10.0)
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        SizedBox(
                                                          height: 0.0,
                                                        ),

                                                        ClipRRect(
                                                          borderRadius: BorderRadius.vertical(top: Radius.circular(4.0)),
                                                          child: CachedNetworkImage(
                                                            imageUrl: exploreArrayValue[index]['image'],
                                                            width: 50.0,
                                                            height: 50.0,
                                                            placeholder: (context,url) => Image.asset('images/no_image.png'),
                                                            errorWidget: (context,url,error) => Image.asset('images/no_image.png'),
                                                          ),
                                                        ),

                                                        SizedBox(
                                                          height: 5.0,
                                                        ),
                                                        Column(
                                                          children: [
                                                            SizedBox(
                                                              width: 2.0,
                                                            ),

                                                            Text(
                                                              exploreArrayValue[index]['category'],
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 11
                                                              ),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                            Text(
                                                              exploreArrayValue[index]['CourseCount'].toString(),
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                color: Colors.black54,
                                                                fontSize: 11,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                              textAlign: TextAlign.center,
                                                            )


                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            })
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
                )
              ],
            ),
          ),
        ));
  }


/*
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        body: SingleChildScrollView(

          child: Stack(
            children: <Widget>[
              Positioned.fill(
                //
                child: Image(
                  image: AssetImage('images/courses_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),


                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, top: 10),
                      width: MediaQuery.of(context).size.width * 0.95,

                      child: TextField(

                        controller: searchText,
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Search',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 32.0, vertical: 14.0),
                            suffixIcon: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(75.0)),
                                borderSide: BorderSide.none),
                            labelStyle:
                            TextStyle(fontSize: 24, color: Colors.black)),
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 75,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.060,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 12),

                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,

                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                          ),
                          Container(
                            //height: 20,
                            child: Text(this.trendingTile,
                                maxLines: 2,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.left),
                          ),
                          SizedBox(height: 14),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5.0),
                            height: MediaQuery.of(context).size.height * 0.30,

                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (arrayValue == null)
                                    ? 0
                                    : arrayValue.length,

                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      var courseId =
                                      arrayValue[index]['courseId'];
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  courseDetailScreen(
                                                      receivedCourseId:
                                                      courseId)));

                                      setState(() {});
                                    },
                                    child: Container(
                                        height: 250.0,
                                        width: 230.0,
                                        child: Card(
                                          elevation: 3.0,
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(8.0)),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                height: 0.0,
                                              ),
                                              ClipRRect(
                                                borderRadius:
                                                BorderRadius.vertical(
                                                    top: Radius.circular(
                                                        4.0)),
                                                child: CachedNetworkImage(
                                                  imageUrl: arrayValue[index]['thumbnail_image'],
                                                  width: MediaQuery.of(context).size.width * 0.95,
                                                  height: MediaQuery.of(context).size.height * 0.15,
                                                  fit: BoxFit.cover,
                                                  placeholder:(context,url) => Image.asset('images/no_image.png'),
                                                  errorWidget: (context,url,error) => Image.asset('images/no_image.png'),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 8.0,
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    right: 8, left: 8),
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      decoration:
                                                      new BoxDecoration(
                                                          color:
                                                          colorSelection,
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              10)),
                                                      alignment:
                                                      Alignment.center,
                                                      height: 20,
                                                      width: 40,
                                                      child: Text(
                                                          arrayValue[index]
                                                          ['course_type'],
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                              color:
                                                              Colors.white,
                                                              backgroundColor:
                                                              colorSelection,
                                                              fontSize: 12,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w600),
                                                          textAlign:
                                                          TextAlign.center),
                                                    ),
                                                    Spacer(),
                                                    Icon(
                                                      Icons.timer,
                                                      color: Colors.black,
                                                      size: 15.0,
                                                    ),
                                                    SizedBox(
                                                      width: 4.0,
                                                    ),
                                                    Text(
                                                      arrayValue[index]
                                                      ['duration'],
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                          fontWeight:
                                                          FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 6.0,
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    right: 8, left: 8),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: <Widget>[

                                                    Text(
                                                        arrayValue[index]
                                                        ['course'],
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600),
                                                        textAlign:
                                                        TextAlign.left),
                                                    SizedBox(height: 8.0),
                                                    Row(
                                                      children: <Widget>[
                                                        RatingBar.builder(
                                                          initialRating: double
                                                              .parse(arrayValue[
                                                          index]
                                                          [
                                                          'star_ratings']
                                                              .toString()),
                                                          minRating: 5,
                                                          itemSize: 15.0,
                                                          direction:
                                                          Axis.horizontal,
                                                          allowHalfRating: true,
                                                          itemCount: 5,
                                                          itemBuilder:
                                                              (context, _) =>
                                                              Icon(
                                                                Icons.star,
                                                                color: Colors.amber,
                                                                size: 10.0,
                                                              ), onRatingUpdate: (double value) {  },
                                                        ),

                                                        Spacer(),
                                                        Text(
                                                            arrayValue[index][
                                                            'students_enrolled']
                                                                .toString() +
                                                                "  Enrolled",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                            textAlign:
                                                            TextAlign.left),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  );
                                }),
                          ),

                          */
/*Container(
                          //padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                          decoration: new BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(5)),
                          alignment: Alignment.center,
                          height: 20,
                          width: 100,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {});

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          exploureFreeClourses()));
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              //mainAxisAlignment: MainAxisAlignment.end,

                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('View More',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.right),
                              ],
                            ),
                          ),
                        ),*//*

                        ],
                      ),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Container(
                      //margin: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(right: 10),
                      //crossAxisAlignment: CrossAxisAlignment.end,
                      //padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),

                      decoration: new BoxDecoration(
                        //  color:  Color.fromARGB(255, 254, 97, 44),
                          gradient: new LinearGradient(
                            colors: [
//                                          Color.fromARGB(255, 148, 231, 225),
                              Color.fromARGB(255, 254, 97, 44),
                              Color.fromARGB(255, 241, 29, 40)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      alignment: Alignment.center,
                      height: 20,
                      width: 90,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {});

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ExploureFreeCourses()));
                        },
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('View More',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
//                SizedBox(
//                  height: MediaQuery.of(context).size.height * 0.013,
//                ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 12),
                      //width: 400,
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Column(
                        /// Add this
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            height: 21,
                            child: Text(this.explloureTitle,
                                maxLines: 2,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.left),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Container(
                            // color: Colors.blue,
                              margin:
                              const EdgeInsets.only(right: 30, left: 30),
                              */
/*padding: EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5.0),*//*

                              //height: MediaQuery.of(context).size.height * 0.30,
                              child: GridView.count(
                                // scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                childAspectRatio: 1.0,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 30,
                                children: List.generate(
                                    (exploreArrayValue == null)
                                        ? 0
                                        : exploreArrayValue.length, (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      var courseId = exploreArrayValue[index]
                                      ['category_id'];
                                      print("category_id ==> : ${courseId}");

                                      var categoryName =
                                      exploreArrayValue[index]['category'];
                                      print(
                                          "categoryName ==> : ${categoryName}");

                                      setState(() {});

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ExploureCategoryCourses(
                                                      receivedCourseId:
                                                      courseId,
                                                      receivedTitleName:
                                                      categoryName)));

                                      */
/*setState(() {});
                                    var courseId = arrayValue[index]['courseId'];
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                courseDetailScreen(
                                                    receivedCourseId: courseId)));*//*

                                      */
/*Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                exploureFreeClourses()));*//*

                                    },
                                    child: Container(
                                        height: 90.0,
                                        width: 100.0,
                                        child: Card(
                                          elevation: 3.0,
                                          color: Colors.white,
                                          margin: EdgeInsets.all(5.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10.0)),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              SizedBox(
                                                height: 0.0,
                                              ),
                                              ClipRRect(
                                                borderRadius:
                                                BorderRadius.vertical(
                                                    top: Radius.circular(
                                                        4.0)),
                                                child: CachedNetworkImage(
                                                  imageUrl: exploreArrayValue[index]['image'],
                                                  width: 50.0,
                                                  height: 50.0,
                                                  placeholder: (context,url) => Image.asset('images/no_image.png'),
                                                  errorWidget: (context,url,error) => Image.asset('images/no_image.png'),
                                                ),
                                              ),
                                              // Image.network('https://img.zcool.cn/community/012157578c405f0000012e7e69e7cd.jpg@1280w_1l_2o_100sh.jpg'),
                                              SizedBox(
                                                height: 5.0,
                                              ),

                                              Column(
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: 2.0,
                                                  ),
                                                  */
/* Container(
                                                  width: 70,
                                                  height: 35,
                                                  child: Text(
                                                      exploreArrayValue[index]
                                                          ['category'],
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      textAlign:
                                                          TextAlign.center),
                                                ),*//*

                                                  Text(
                                                      exploreArrayValue[index]
                                                      ['category'],
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 11,
                                                          fontWeight:
                                                          FontWeight.w600),
                                                      textAlign:
                                                      TextAlign.center),
                                                  Text(
                                                      exploreArrayValue[index]
                                                      ['CourseCount']
                                                          .toString(),
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: 11,
                                                          fontWeight:
                                                          FontWeight.w500),
                                                      textAlign:
                                                      TextAlign.center),
                                                ],
                                              ),
                                              //SizedBox(height: 16.0),

                                              // SizedBox(height: 16.0,),
                                            ],
                                          ),
                                        )),
                                  );
                                }),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
*/
}
