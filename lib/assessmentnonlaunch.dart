import 'package:flutter/material.dart';

class AssessmentNonDegree extends StatefulWidget {
  const AssessmentNonDegree({Key? key}) : super(key: key);

  @override
  _AssessmentNonDegreeState createState() => _AssessmentNonDegreeState();
}

class _AssessmentNonDegreeState extends State<AssessmentNonDegree> {
  int checkingValue = 4;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/fita-app-bakground-xxxhdpi-3x.png",),
            fit: BoxFit.cover
          )
        ),
        child: Column(
          children: [
            SizedBox(height: 50),
            Row(
              children: [
                IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 30,
                    )
                )
              ],
            ),
            SizedBox(height: 200),
            GestureDetector(
              onTap: (){
                checkingValue = 1;
                print('FirstTap');
                setState(() {});
              },
              child: Card(
                color: (checkingValue == 1) ? Colors.blueAccent : Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.75,
                  color:
                  (checkingValue == 1)? Colors.blueAccent : Colors.white,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                        child: Image.asset(
                          "images/rec.png",
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                        color: (checkingValue == 1) ?
                          Colors.white
                          :Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "I am undergoing a degree related to Computer Science / Software / IT",
                          style: (checkingValue == 1)
                          ? TextStyle(color: Colors.white, fontSize: 14)
                          : TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: (){
                checkingValue = 2;
                print("SecondTap");
                setState(() {});
              },
              child: Card(
                color: Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Container(
                  color: (checkingValue == 2) ? Colors.blueAccent : Colors.white,
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                        child: Image.asset(
                          "images/rec.png",
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                          color: (checkingValue == 2)?
                          Colors.white
                          :Colors.black,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "I am undergoing a Non - Computer Science / Software / IT  Degree ",
                          style:
                              (checkingValue == 2)? TextStyle(color: Colors.white,fontSize: 14)
                                  : TextStyle(color: Colors.black, fontSize: 14)

                        ),
                      )
                    ],
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
