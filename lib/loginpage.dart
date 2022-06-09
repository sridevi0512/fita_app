import 'package:fita_app/loginmainpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  "images/logo.jpg",
                      fit:BoxFit.fill,
                ),

                ),
              SizedBox(width: 5),
              Center(
                child: ElevatedButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginMainPage()),
                  );
                },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(width:2.0,color: Color(0xff0773d5))
                            )
                        )
                    ),


                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                        child:Text('SignUp\n /Login',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(color:Colors.black,
                              fontWeight: FontWeight.bold),)
                    )

                ),
              )


            ],
          ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child:
                    Text("Under \n Construction",
                      textAlign: TextAlign.center,
                      style:  TextStyle(
                          color: Colors.black,
                          fontSize: 45.0,
                          fontWeight: FontWeight.bold
                      ),),




                  )

                ],
              )




        ],
      )
      ),
    );
  }
}
