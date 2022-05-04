import 'dart:convert';

import 'package:first_app/utils/apiUrl.dart';
import 'package:first_app/utils/constants.dart';
import 'package:first_app/utils/preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'detailconcernpage.dart';

class ConcernStatusClass extends StatefulWidget {
  const ConcernStatusClass({Key? key}) : super(key: key);

  @override
  _ConcernStatusClassState createState() => _ConcernStatusClassState();
}

class _ConcernStatusClassState extends State<ConcernStatusClass> {
  var raiseConcernList = [];
  Color? colorSelection;
  String studentMessage = '', adminMessage = '';
  String isLoaded = 'null';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRaiseConcernList();
  }

  Future<String?> getRaiseConcernList() async {
    raiseConcernList.clear();
    print('Notification');
    final response = await http.post(Uri.parse(ApiUrl.BASE_COURSE_URL + ApiUrl.CONCERN_STATUS ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
        },
        body: jsonEncode(<String, String> {
          'pageno': "1",
        })
    );
    try{
      if(response.statusCode == 200) {
        isLoaded = 'true';
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['concerndata'];
        setState(() {
          raiseConcernList = data;
          print('raisedConcernList -> ${raiseConcernList.toString()}');
        });
        print("raisedConcern IN TRY");
      }
    }catch (Exception){
      print(Exception);
      print("Failed to load");

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Concern Status"),
        actions: [],
      ),
      body: isLoaded == "true"?
      Container(
        child: ListView.builder(
          itemCount: (raiseConcernList == null)? 0 : raiseConcernList.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailConcernStatusClass(
                            studentMessage: raiseConcernList[index]['studentconcern_message'],
                            adminMessage: raiseConcernList[index]['adminreply']
                        )
                    )
                );
              },
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 10,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Image.asset(
                                  'images/concern_icon.jpg',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(
                                  height: 10
                              ),
                              Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3)
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: (raiseConcernList[index]['status'] == 'Open')
                                            ? Colors.red
                                            :(raiseConcernList[index]['status'] == 'In Progress')
                                            ? Colors.orange
                                            : Colors.green
                                    ),
                                    child: (raiseConcernList[index]['status'] == 'Open')
                                        ? Text(raiseConcernList[index]['status'],
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ):
                                    (raiseConcernList[index]['status'] == 'In Progress')
                                        ? Text(
                                      raiseConcernList[index]['status'],
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ) :
                                    (raiseConcernList[index]['status'] == 'Resolved')
                                        ? Text(raiseConcernList[index]['status'])
                                        : Text('Null')

                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 14,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Batch code" +
                                        raiseConcernList[index]['batch_code'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.02,
                                  ),
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: 'Concern Id: ',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  backgroundColor: this.colorSelection,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold
                                              )
                                          ),
                                          TextSpan(
                                              text: raiseConcernList[index]['concern_code'],
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  backgroundColor: this.colorSelection,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal
                                              )
                                          )
                                        ]
                                    ),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.002),
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    text: TextSpan(
                                        children: <TextSpan> [
                                          TextSpan(
                                              text: 'Course Name: ',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  backgroundColor: this.colorSelection,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12
                                              )
                                          ),
                                          TextSpan(
                                              text: raiseConcernList[index]['course_name'],
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  backgroundColor: this.colorSelection,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal
                                              )
                                          )
                                        ]
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.002,
                                  ),
                                  RichText(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: 'Course Mode: ',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  backgroundColor: this.colorSelection,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold
                                              )
                                          ),
                                          TextSpan(
                                              text: raiseConcernList[index]['course_mode'],
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                  backgroundColor: this.colorSelection
                                              )
                                          )
                                        ]
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.002,
                                  ),
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    text: TextSpan(children:
                                    <TextSpan>[
                                      TextSpan(
                                          text: 'Student Concern: ',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              backgroundColor: this.colorSelection
                                          )
                                      ),
                                      TextSpan(
                                          text: raiseConcernList[index]['studentconcern_message'],
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12,
                                              backgroundColor: this.colorSelection
                                          )
                                      )
                                    ]),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.005,
                                  ),

                                ],
                              )
                            ],
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
      ):
      isLoaded == 'false'
          ?Container(
        alignment: Alignment.center,
        child: Center(
          child: Text(
            'No Concern status available',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600
            ),
          ),
        ),
      ):
      Container(

      ),
    );
  }
}
