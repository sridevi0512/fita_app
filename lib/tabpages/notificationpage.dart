import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fita_app/main.dart';
import 'package:fita_app/notificationClickedPage.dart';
import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../lectureReview.dart';

class NotificationClass extends StatefulWidget {
  const NotificationClass({Key? key}) : super(key: key);

  @override
  _NotificationClassState createState() => _NotificationClassState();
}



class _NotificationClassState extends State<NotificationClass> {
  var notificationList = [];
  var notificationListmsg = [];
  String isEmptyList = "null";
  bool toVisible = false;
  bool toVisiblemsg = false;
  Color? colorSelectionValue;
  String link = "";
  String notify_message = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotificationList();
  }

  Future<String?> getNotificationList() async{
    notificationList.clear();
    print(ApiUrl.BASE_COURSE_URL + ApiUrl.NOTIFICATION_LIST);
    final response = await http.post(
        Uri.parse(ApiUrl.BASE_COURSE_URL + ApiUrl.NOTIFICATION_LIST),
        headers: <String,String> {
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
        },
        body: jsonEncode(<String, String>{
          'pageno' : "1"
        })
    );
    try{
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['notificationdata'];
        print("Notification data ==> ${data.toString()}");
        setState(() {
          notificationList = data;
          if(data.isEmpty){
            showAlertDialog(context);
          } else {
            isEmptyList = "";
          }
        });
        print('NOTIFICATION in TRY');
      } else {
        var jsonData1 = jsonDecode(response.body);
        Fluttertoast.showToast(msg: jsonData1['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
        Navigator.pop(context);
        print('Notification Error in IF ELSE');
      }
    }catch (Exception) {
      print('Exception: ${Exception.toString()}');
      Navigator.pop(context);
    }

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

  Future<String?> notificationYesClickApi() async {
    showLoaderDialog(context);
    FocusScope.of(context).unfocus();
    final response = await http.post(
        Uri.parse(ApiUrl.BASE_COURSE_URL + ApiUrl.NOTIFICATION_YES),
        headers: <String,String>{
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
        },
        body: jsonEncode({
          'notification_id' :
          Preference.getNotificationId(Constants.NOTIFICATION_ID),
          "readnotification" : true,
        })
    );
    print("NotificationId ==> ${Preference.getNotificationId(Constants.NOTIFICATION_ID)}");
    try{
      var jsonData = jsonDecode(response.body);
      if(response.statusCode == 200){
        // Navigator.pop(context);
        getNotificationList();
        var data = jsonData['data'];
        print("DATA: ${data.toString()}");
        Fluttertoast.showToast(msg: jsonData['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
        setState(() {});
      }else {
        print(Preference.getAuthToken(Constants.AUTH_TOKEN));
        print(jsonData['status']['message']);
        print(Preference.getNotificationId(Constants.NOTIFICATION_ID));
        Fluttertoast.showToast(msg: jsonData['status']['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM
        );
        Navigator.pop(context);
      }
    }catch (Exception) {
      Navigator.pop(context);
      print("Exception: ${Exception.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        automaticallyImplyLeading: false,
        actions: [],
      ),
      body: Container(
        child: (notificationList.length != 0)?
        ListView.separated(
          shrinkWrap: true,
          itemCount: notificationList.length,
          separatorBuilder: (context,index) {
            return Divider(
              height: 5,
            );
          },
          itemBuilder: (BuildContext context, int index) {
            link = notificationList[index]['batch_meeting_details'];
            notify_message = notificationList[index]['notify_message'];
            print("link $link");
            print("notify_msg $notify_message");
            var msg = notificationList[index]['course_complited_discription'];
            // msg.add(notificationList[index]['course_complited_discription']);
            print(msg);
            notificationList[index]['notify_identity'] == "" && notificationList[index]['notify_identity'] == "new student"
                ? this.toVisible = true
                : this.toVisible = false;
            msg!=null && msg == []
                ? this.toVisiblemsg = true
                : this.toVisiblemsg = false;

            return Padding(
              padding: EdgeInsets.all(8),
              child: Card(
                child: GestureDetector(
                  onTap: (){
                    Navigator.of(context)
                        .push(MaterialPageRoute
                      (builder: (BuildContext context) => NotificationClickedPage(
                      "meet_link" : link,
                      "notify_message" : notify_message
                    )));
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          // height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width,
                          child: CachedNetworkImage(
                            imageUrl: notificationList[index]['course_image'],
                            fit: BoxFit.fill,
                            placeholder: (context,url) => Container(),
                            errorWidget: (context,url,error) => Container(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Batch Code: ' +notificationList[index]['batch_code'],
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black
                                  ),
                                ),
                                SizedBox(height: 5),
                                MergeSemantics(
                                  child: Row(
                                    children: [
                                      SizedBox(height: 5),
                                      Flexible(
                                        child:Text(
                                          'Course Name: ' + notificationList[index]['course_name'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                   notificationList[index]['notify_message'] + "Happy Learning!",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black
                                  ),
                                ),
                                Visibility(
                                  visible: this.toVisiblemsg,
                                  child: (msg!=null)?
                                  SizedBox(height: 5):
                                  SizedBox(height: 0),
                                ),
                                Visibility(
                                    visible: this.toVisiblemsg,
                                    child: (msg
                                        != null)?
                                    Text(
                                      'Placement Message: ' +
                                          msg.toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.black,
                                          backgroundColor: this.colorSelectionValue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal
                                      ),
                                    ) : Text('')
                                ),
                                SizedBox(height: 5),
                                Visibility(
                                  visible: this.toVisible,
                                  child: (notificationList[index]['notify_identity'])
                                      == ""
                                      ? Text(
                                    'Session Date: ' + notificationList[index]['session_date'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.black,
                                        backgroundColor: this.colorSelectionValue,
                                        fontSize: 12,

                                    ),
                                  )
                                      : Text(notificationList[index]['notify_message']),
                                ),
                                Visibility(
                                  visible: this.toVisible,
                                  child: SizedBox(height: 5),
                                ),
                                Visibility(
                                    visible: this.toVisible,
                                    child: (notificationList[index]['notify_identity']
                                        == "")?
                                    Text(
                                      'Session Time: ' +
                                          notificationList[index]['session_fromtime'] +
                                          " - " +
                                          notificationList[index]['session_totime'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.black,
                                          backgroundColor: this.colorSelectionValue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal
                                      ),
                                    ) : Text('')
                                ),
                                Visibility(
                                  visible: this.toVisible,
                                  child: (notificationList[index]['notify_identity'] != "")
                                      ? Text(
                                    'Message: ' +
                                        notificationList[index]['notify_message'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.black,
                                        backgroundColor: this.colorSelectionValue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal
                                    ),
                                  ): Text(''),
                                ),
                                Visibility(
                                  visible: this.toVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      (notificationList[index]['notify_identity'] == "")?
                                      Text(
                                        'Happy with your class on ' +
                                            notificationList[index]['session_date'] +
                                            '?',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal
                                        ),
                                      ): Text(''),
                                      SizedBox(height: 5),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  Preference.setNotificationId(Constants.NOTIFICATION_ID,
                                                      notificationList[index]['_id']);
                                                  notificationYesClickApi();
                                                });
                                              },
                                              child: Card(
                                                color: Colors.green,
                                                elevation: 5.0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(3.0)
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: Container(
                                                  margin: EdgeInsets.all(3),
                                                  child: Text(
                                                    'YES',
                                                    style: TextStyle(
                                                        color: Colors.white
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(left: 10,right: 10,top: 2,bottom: 2),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                              width: 15,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            LectureReviewClass(
                                                                lectureName: notificationList[index]['trainer_name'],
                                                                courseName: notificationList[index]['course_name'],
                                                                courseImage: notificationList[index]['course_image'],
                                                                notification_id: notificationList[index]['_id']
                                                            )));
                                                setState(() {});
                                              },
                                              child: Card(
                                                color: Colors.red,
                                                elevation: 5.0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(3.0)
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: Container(
                                                  margin: EdgeInsets.all(3),
                                                  child: Container(
                                                    margin: EdgeInsets.all(3),
                                                    child: Text(
                                                      'NO',
                                                      style: TextStyle(
                                                          color: Colors.white
                                                      ),
                                                    ),
                                                    padding: EdgeInsets.only(top: 2,bottom: 2,left: 10,right: 10),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )

                              ],
                            )
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ): Container(
          /*child: Center(
            child: CircularProgressIndicator(),
          ),*/
        ),
      ),
    );
  }
}
