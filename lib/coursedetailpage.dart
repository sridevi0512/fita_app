import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:first_app/utils/apiUrl.dart';
import 'package:first_app/utils/constants.dart';
import 'package:first_app/utils/preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:need_resume/need_resume.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

import 'coursepaymentpage.dart';
import 'coursevideoclass.dart';
import 'main.dart';

class courseDetailScreen extends StatefulWidget {
  String receivedCourseId;


  @override
  _courseDetailScreenState createState() => _courseDetailScreenState();
  courseDetailScreen({Key? key, required this.receivedCourseId}) : super(key: key);
}

class _courseDetailScreenState extends ResumableState<courseDetailScreen> {
  TargetPlatform? _platform;




  List<bool> isSyllabusClicked = [];
  List<bool> isFaqClicked = [];
  var arrayValue;
  var syllabusArray;
  var certificationImageArray;
  var faqArray;
  int checkingvalue = -1;
  int checkingvalue1 = -1;
  bool isVisibleClicked = false;
  bool visible = true;
  bool visible1 = false;
  int pla = 0;
  bool enrollment = false;
  bool hasKeySkill = false;

  int mySide = -1;
  var imageTag;
  var name = '';
  var name1 = '';
  int i = 0;

  String enrollTxt = '';
  String courseTitle = '';
  String videoThumb = '';
  var courseEnrolled = "";

  List selectedRows = [int];

  double? ratingValue;
  List<String> keySkillsArray = [];
  VideoPlayerController? controller;
  ChewieController? _chewieController;
  ImageIcon? faqImage;
  ImageIcon? faqImage1;
  CachedNetworkImage? playingThumbimg;
  ImageIcon plusImage = ImageIcon(
    AssetImage("images/plus_icon.png"),
    color: Colors.deepOrange,
  );

  ImageIcon minusImage = ImageIcon(
    AssetImage("images/minus_icon.png"),
    color: Colors.deepOrange,
  );
  String tagImg = '';
  String videoURL = '';
  var expandImg = [
    ImageIcon(
      AssetImage("images/plus_icon.png"),
      color: Colors.deepOrange,
    )
  ];

  List rowchecked = [int];
  var videoTimer = "";
  var courseCompleted;

  void onReady() {

    print('HomeScreen is resumed!');
  }

  @override
  void onResume() {

    this.courseDetailApiResponse();
    print('HomeScreen is resumed!');
  }

  @override
  void onPause() {

    print('HomeScreen is paused!');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('courseId =>' + this.widget.receivedCourseId);
    Preference.setCourseId(Constants.COURSE_ID, this.widget.receivedCourseId);
    print("UserId=> ${Preference.getUserId(Constants.USER_ID)}");
    this.courseDetailApiResponse();
    faqImage = plusImage;
    faqImage1 = plusImage;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller!.dispose();
    _chewieController!.dispose();
  }

  Future<String?> courseDetailApiResponse() async {
    print(
        ApiUrl.BASE_URL_Test + ApiUrl.COURSE_DETAIL
            + this.widget.receivedCourseId
    );
    print('Course Id ==>' + this.widget.receivedCourseId);
    final response = await http.get(Uri.parse(ApiUrl.BASE_URL_Test +
        ApiUrl.COURSE_DETAIL +
        this.widget.receivedCourseId +
        "/" +
        Preference.getUserId(Constants.USER_ID)),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
      },
    );
    print('User ID: ' + Preference.getUserId(Constants.USER_ID));
    if(response.statusCode == 200) {
      var jsonData = json.decode(utf8.decode(response.bodyBytes));

      var data = jsonData['data'];
      print("data_course ${(data.toString())}");
      this.courseTitle = data['course'];
      this.videoThumb = data['thumbnail_image'];
      this.videoURL = data['video'];
      this.videoTimer = data['video_timer'].toString();
      this.enrollment = data['enrollment'];
      this.courseCompleted = data['course_completed'].toString();

      print('videoTimer==> ' + data["video_timer"].toString());
      print('course_enrolled==> ' + data['course_enrolled'].toString());
      print('courseCompleted ==> ${data['course_completed'].toString()}');

      if(localStore == "exploureFreeCourse") {
        this.tagImg = "images/free_tag.png";
        this.enrollTxt = "Learn this Course";
      } else {
        if (this.enrollment) {
          this.enrollTxt = "Enrolled";
        } else {
          this.enrollTxt = "Enroll Now";

          this.tagImg = "";
        }
      }
      setState(() {
        this.arrayValue = data;
        this.syllabusArray = data['syllabus'];
        this.faqArray = data['FAQ'];
        Preference.setCourseName(Constants.COURSE_NAME, data['course']);
        this.certificationImageArray = data['certification_image'];
        String skills = data["key_skills"];
        this.keySkillsArray = skills.split(",");
        print("Skills + ${data['key_skills'].toString()}");
        print("Skills ls + ${keySkillsArray.toString()}");
        print("faq Array: ${this.faqArray}");
        if(keySkillsArray.toString() != "[--]"
            && keySkillsArray.toString() != "[no]"
            &&  keySkillsArray.toString() != "[----]"){
          hasKeySkill = true;
        }

        this.playingThumbimg = CachedNetworkImage(
          imageUrl: arrayValue['thumbnail_image'],
          fit: BoxFit.cover,
          placeholder: (context,url) => Image.asset('images/no_image.png'),
          errorWidget: (context,url,error) => Image.asset('images/no_image.png'),
        );
        isSyllabusClicked = List<bool>.filled(this.syllabusArray.length, false);
        isFaqClicked = List<bool>.filled(this.faqArray.length, false);

      });
    } else {

      var jsonDataError = jsonDecode(response.body);
      print('RETURN RES COURSE DETAIL: + ${jsonDataError.toString()}');

      throw Exception('Failed to load');

    }

  }

  Future<String?> freeCourseEnrolled() async {
    print("freeEnrolled");

    final response =
    await http.post(Uri.parse(ApiUrl.BASE_URL_Test + ApiUrl.Free_Enrolled_Course),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
        },
        body: jsonEncode(<String, String>{
          "course_id": this.widget.receivedCourseId,
          "user_id": Preference.getUserId(Constants.USER_ID)
        }));
    if(response.statusCode == 200){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CourseVideoClass(
                courseTitle: this.courseTitle,
                videoThumb: this.videoThumb,
              )
          ));
      print('Video URL => ' + this.videoURL);
    } else {
      throw Exception('Failed to load');
    }
  }





  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).textScaleFactor;
    print("fontSize :" + fontSize.toString());
    return SafeArea(

      child: Scaffold(
        body: SingleChildScrollView(

          child: Container(
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  overflow: Overflow.visible,
                  children: [
                    Container(
                        height: 400,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  'images/tool_bar_image.png'),
                              fit: BoxFit.cover,
                            )
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: new Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                    size: 25.0,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                (arrayValue != null)?
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.85,
                                  child:
                                  (fontSize == 1.0)?
                                  Text(
                                    (arrayValue == null) ?
                                    "" :
                                    this.arrayValue['course'],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: (arrayValue['course'].length>10)? 18 : 22,
                                        fontWeight: FontWeight.w600
                                    ),
                                    textAlign: TextAlign.center,
                                  ):
                                  Text(
                                    (arrayValue == null) ?
                                    "" :
                                    this.arrayValue['course'],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: (arrayValue['course'].length>10)? 17 : 22,
                                        fontWeight: FontWeight.w600
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ):
                                Container(
                                  child: Text(
                                    "",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                                ,
                                SizedBox(
                                  height: 15,
                                  width: 10,
                                ),
                                Container(
                                  width: 200,
                                  height: 60,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          RatingBar.builder(
                                            initialRating: double.parse(
                                                (arrayValue == null)?
                                                "0" :
                                                arrayValue['total_ratings'].toString()
                                            ),
                                            maxRating: 5,
                                            itemCount: 5,
                                            itemSize: 25.0,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemBuilder: (context, _) => Icon(Icons.star,
                                              color: Colors.amber,
                                              size: 10.0,
                                            ), onRatingUpdate: (double value) {  },
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        (arrayValue == null)?
                                        "":
                                        arrayValue['total_ratings'].toString() + " Ratings",
                                        maxLines: 2,
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: (fontSize == 1.0)?15: 16,
                                            fontWeight: FontWeight.normal
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                                Container(
                                  margin: EdgeInsets.only(left: 20, right: 20),
                                  child:Row(

                                    children: [
                                      Text(
                                        (arrayValue == null)?
                                        "":
                                        arrayValue['students_enrolled'].toString() +
                                            " Enrolled",
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: (fontSize == 1.0)?15:16,
                                            fontWeight: FontWeight.normal
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.timer,
                                        color: Colors.white,
                                        size: 15.0,

                                      ),
                                      SizedBox(width: 4.0),

                                      Text(
                                        (arrayValue == null)?
                                        " " :
                                        arrayValue['duration'].toString() + " Duration",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.normal,
                                            fontSize: (fontSize == 1.0)?15:16
                                        ),
                                      )

                                    ],
                                  ),
                                ),



                              ],
                            ),



                          ],
                        )
                    ),
                    Positioned(
                        left: 20,
                        right: 20,
                        top: 205,
                        child:
                        Container(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black38,
                                        blurRadius: 55,
                                        offset: const Offset(0, 30)
                                    ),
                                  ],
                                ),
                                margin: const EdgeInsets.only(bottom: 8),
                                width: MediaQuery.of(context).size.width * 0.95,
                                height: 250,
                                child: this.playingThumbimg,
                              ),
                            ],
                          ),
                        )
                    ),
                    (localStore == "exploureFreeCourse")?
                    Positioned(
                      bottom: -80,
                      left: 25,
                      child: Container(
                        height: 60,
                        width: 60,

                        child: new Image.asset(
                          (localStore == "exploureFreeCourse")?
                          "images/free_tag.png" : "",
                          width: 16.0,
                          height: 16.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ):
                    Container(),
                    Positioned(
                        bottom: 10,
                        child: Container(
                          height: 50,
                          width: 50,
                          alignment: Alignment.center,
                          child: FloatingActionButton(
                            backgroundColor: Colors.transparent,
                            onPressed: (){
                              setState(() {
                                _platform = TargetPlatform.iOS;
                                _chewieController!.dispose();
                                controller!.pause();
                                controller!.seekTo(const Duration());
                                controller = ChewieController(
                                  videoPlayerController: controller!,
                                  autoPlay: true,
                                  looping: true,
                                ) as VideoPlayerController?;

                              });
                            },
                          ),
                        )
                    ),
                  ],
                ),

                SizedBox(
                  height: 100,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  // height: 50,
                  child: RaisedButton(
                    color: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 0,horizontal: 0),
                    onPressed: (){
                      if(this.enrollTxt == "Learn this Course"){
                        print("Course Completed: ${this.courseCompleted}");
                        if(this.courseCompleted == "false" || this.courseCompleted == 0) {
                          this.freeCourseEnrolled();
                        }else{
                          Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (context) => CourseVideoClass(
                                      courseTitle: this.courseTitle,
                                      videoThumb: this.videoThumb)
                              )
                          );
                        }
                      }else {
                        if(!enrollment) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CoursePaidPaymentScreen(receivedCourseId: this.widget.receivedCourseId)
                              ));
                        }else{
                          Fluttertoast.showToast(msg: 'You have already enrolled this course',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM);
                        }
                      }
                      setState(() {});
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        decoration: new BoxDecoration(
                            gradient: new LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 254, 97, 44),
                                  Color.fromARGB(255, 241, 29, 40),
                                ] )
                        ),
                        padding: EdgeInsets.all(15.0),

                        child:Text(
                          this.enrollTxt.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600
                          ),
                          textAlign: TextAlign.center,
                        )
                    ),
                  ),
                ),

                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.only(left: 15,right: 5),
                  padding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "About this Course",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: (fontSize == 1.0)?20:21
                        ),
                        textAlign: TextAlign.left,
                      ),
                      HtmlWidget(
                        (arrayValue == null)? "" : arrayValue['description'],
                       /* style: {
                          "body": Style(
                            color:Colors.black,
                            fontSize: FontSize(15.0),
                            fontWeight: FontWeight.normal,
                          ),
                        },*/

                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal
                        ),
                      ),


                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 5, left: 0),
                        padding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 0.0),

                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Visibility(
                        visible: hasKeySkill,
                        child:  Text(
                          "Key Skills Covered",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: (fontSize == 1.0)?20:21,
                              fontWeight: FontWeight.w600
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Visibility(
                        visible: hasKeySkill,
                        child:SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                      ),
                      Visibility(
                        visible: hasKeySkill,
                        child: Container(
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: (this.keySkillsArray == null) ?
                              0 : this.keySkillsArray.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 18),
                                        ),
                                        ImageIcon(
                                          AssetImage("images/tick_icon.png"),
                                          color: Colors.deepOrange,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.07,
                                        ),
                                        Flexible(child:
                                        Text(
                                          (this.keySkillsArray == null)?
                                          "": this.keySkillsArray.toString(),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              fontFamily: 'Montserrat'
                                          ),
                                        ),
                                        )
                                      ],
                                    )
                                  ],
                                );
                              }),
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.020,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                          ),
                          Text(
                            "Course Syllabus",
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          Container(
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.all(0.0),
                              itemCount: (syllabusArray == null)? 0 : syllabusArray.length,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      /* if(!isSyllabusClicked){
                                        isSyllabusClicked = true;
                                      }else {
                                        isSyllabusClicked = false;

                                      }
                                      print("statusClicked: ${isSyllabusClicked.toString()}");*/
                                    });
                                  },
                                  child: ListTileTheme(
                                    horizontalTitleGap: 0.0,
                                    dense: true,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent
                                      ),
                                      child: ExpansionTile(
                                        onExpansionChanged: (bool isExpanded) {
                                          checkingvalue = index;
                                          setState(() {
                                            isSyllabusClicked[index] = isExpanded;
                                          });
                                        },
                                        trailing: SizedBox.shrink(),
                                        leading: isSyllabusClicked[index]
                                            ? minusImage: plusImage,
                                        title: Text(
                                          syllabusArray[index]['title'],
                                          maxLines:2,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize:15,
                                              fontWeight: FontWeight.w600
                                          ),
                                        ),
                                        children: [
                                          ListTile(
                                            title: HtmlWidget(
                                             syllabusArray == null? "" : syllabusArray[index]['description'],
                                             /* style: {
                                                "body": Style(
                                                  color:Colors.black,
                                                  fontSize: FontSize(15.0),
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              },*/
                                              textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal
                                              ),
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                          ),
                          Text(
                            "FAQ",
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 20
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                          Container(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: this.faqArray == null ? 0 : faqArray.length,
                              itemBuilder: (BuildContext context, int index) {

                                return GestureDetector(

                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ListTileTheme(
                                          horizontalTitleGap: 0.0,
                                          child: Theme(
                                            data: Theme.of(context).copyWith(
                                                dividerColor: Colors.transparent
                                            ),
                                            child: ExpansionTile(
                                              onExpansionChanged: (bool value) {
                                                checkingvalue = index;
                                                print(value);
                                                setState(() {
                                                  isFaqClicked[index] = value;
                                                });

                                              },
                                              trailing: SizedBox.shrink(),
                                              leading:  isFaqClicked[index]
                                                  ? minusImage: plusImage,
                                              title: Text(
                                                faqArray[index]['title'],
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black
                                                ),
                                              ),
                                              children: [
                                                ListTile(
                                                  title:
                                                  HtmlWidget(
                                                    (faqArray == null)? "" :
                                                    faqArray[index]['description'],
                                                    textStyle: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.normal,
                                                        color: Colors.black
                                                    ),

                                                    /*style: {
                                                      "body": Style(
                                                          color:Colors.black,
                                                          fontSize: FontSize(15.0),
                                                          wordSpacing: 5,
                                                          fontWeight: FontWeight.normal,
                                                          listStyleType:ListStyleType.UPPER_ALPHA
                                                      ),
                                                    },
*/
                                                    /*customRender: {
                                                      "li": (RenderContext context, Widget child) {
                                                        return this.customListItem(*//*element*//*);
                                                      },
                                                    },*/


                                                  ),

                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )

                                );
                              },
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.020,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20)
                              ),
                              Text(
                                "Certification :",
                                textScaleFactor: 1.0,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.01,
                              ),
                              Container(
                                child: Flexible(
                                  child:HtmlWidget(
                                    (arrayValue == null)? "":
                                    arrayValue['certification'],
                                   /* style: {
                                      "body": Style(
                                        color:Colors.black,
                                        fontSize: FontSize(15.0),
                                        fontWeight: FontWeight.normal,
                                      ),
                                    },*/
                                     textStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal
                                    ),
                                  ),

                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.01,
                              ),
                              Container(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: this.certificationImageArray == null ? 0 : certificationImageArray.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {},
                                      child: Column(
                                        children: [
                                          Padding(padding: EdgeInsets.only(left: 20)),
                                          CachedNetworkImage(
                                            imageUrl: this.certificationImageArray == null? "" :
                                            this.certificationImageArray[index].toString(),
                                            fit: BoxFit.contain,
                                            placeholder: (context,url) => Image.asset("images/no_image.png"),
                                            errorWidget: (context,url,error) => Image.asset("images/no_image.png"),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          )
                        ],
                      )


                    ],
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
/* Widget htmlCustomRenderer(dom.Node node, List<Widget> children){
    if(node is dom.Element) {
      switch (node.localName) {
        case "li":
          return customListItem(node);
      }
    }
    return null;

  }
  Wrap customListItem(*//*dom.Element node*//*) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: CircleAvatar(
            radius: 2,
          ),
        ),
        Text(node.text)
      ],
    );
  }*/

}
