import 'package:bubble/bubble.dart';
import 'package:first_app/utils/constants.dart';
import 'package:first_app/utils/preference.dart';
import 'package:flutter/material.dart';

class DetailConcernStatusClass extends StatefulWidget {
  String studentMessage,adminMessage;

  @override
  _DetailConcernStatusClassState createState() => _DetailConcernStatusClassState();
  DetailConcernStatusClass({Key? key, required this.studentMessage,required this.adminMessage}) : super(key: key);

}

class _DetailConcernStatusClassState extends State<DetailConcernStatusClass> {
  bool isEmpty = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(this.widget.adminMessage == "") {
      isEmpty = false;
    }else {
      isEmpty = true;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recent Comments'),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: ExactAssetImage('images/courses_bg.png'),
                fit: BoxFit.cover
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                          "images/concern_icon.jpg",
                          height: 50,
                          width: 50
                      ),
                      Text(
                        Preference.getFirstName(Constants.FIRST_NAME) +
                            " " +
                            Preference.getLastName(Constants.LAST_NAME),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black
                        ),
                      )
                    ],
                  ),
                  Bubble(
                    margin: BubbleEdges.only(top: 10),
                    nip: BubbleNip.rightBottom,
                    color: Color.fromRGBO(225, 255, 199, 1.0),
                    child: Text(
                      this.widget.studentMessage,
                      textAlign: TextAlign.right,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Visibility(
              visible: isEmpty,
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          "images/concern_icon.jpg",
                          height: 50,
                          width: 50,
                        ),
                        Text(
                          'Admin',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black
                          ),
                        )
                      ],
                    ),
                    Bubble(
                      margin: BubbleEdges.only(top: 10),
                      color: Color.fromRGBO(212, 234, 244, 1.0),
                      nip: BubbleNip.leftTop,
                      child: Text(
                        this.widget.adminMessage,
                        textAlign: TextAlign.left,
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Only',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            )
                        ),

                        TextSpan(
                            text: "Admin ",
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.w500
                            )
                        ),
                        TextSpan(
                            text: "can send messages",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500
                            )
                        )
                      ]
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
