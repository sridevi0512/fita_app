import 'package:firebase_auth/firebase_auth.dart';
import 'package:fita_app/main.dart';
import 'package:fita_app/registerscreen.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GmailScreen extends StatefulWidget {
  String userId, userToken;

  @override
  _GmailScreenState createState() => _GmailScreenState();
   GmailScreen({Key? key, required this.userId,required this.userToken}) : super(key: key);

}

class _GmailScreenState extends State<GmailScreen> {
  bool isClicked = false;
  bool checkingvalue = false;
  bool showingOriginalWidget = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future googleLogin() async {
    showLoaderDialog(context);
    final GoogleSignInAccount? googleSignInAccount =
    await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken
    );

    final UserCredential authResult = await _auth.signInWithCredential(
        credential);
    final User? user = authResult.user;

    final User currentUser = await _auth.currentUser!;
    print("email:${currentUser.email}");
    print("uid:${currentUser.uid}");
    print("phonenumber: ${currentUser.phoneNumber}");
    print('first name:${currentUser.displayName!.split(" ")[0].toString()}');
    print('last name: ${currentUser.displayName!.split(" ")[1].toString()}');
    print('photourl:${currentUser.photoURL}');

    Navigator.pop(context);
    Navigator.push(context,
        PageRouteBuilder(pageBuilder: (context, animation1, animation2) {
          return RegisterScreen(
            userId: widget.userId,
            firstName: currentUser.displayName!.split(" ")[0].toString(),
            lastName: currentUser.displayName!.split(" ")[1].toString(),
            email: currentUser.email.toString(),
            token: Preference.getAuthToken(Constants.AUTH_TOKEN),
            auth: "gmail",
          );
        },
            transitionsBuilder: (context, animation1, animation2, child) {
              return FadeTransition(opacity: animation1,
                  child: child);
            },
            transitionDuration: Duration(milliseconds: 1)
        )
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Navigator.of(context,rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    void changeToCard() {
      Card(
        color: isClicked == false ? Colors.blue : Colors.white,
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              isClicked = false;
              showingOriginalWidget = !showingOriginalWidget;
            });

            _googleSignIn.disconnect();
            googleLogin();
          },
          // highlightElevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                child:Image(
                    image: ExactAssetImage("images/g_logo_60.png"),
                    height: 35.0),
                ),
                Expanded(
                  child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Sign in with Google',
                    style: TextStyle(
                        fontSize: 20,
                        color: isClicked == false ? Colors.white : Colors.blue
                    ),
                  ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    void changeToText() {
      Text(
        'sign in with Google',
        style: TextStyle(color: Colors.blue),
      );
    }

    return SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            toolbarHeight: MediaQuery
                .of(context)
                .size
                .height * 0.15,
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back_ios),
                    iconSize: 18,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16
                  ),

                )
              ],
            ),
          ),

          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/courses_bg.png'),
                  fit: BoxFit.cover,
                )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.80,
                  child: Card(
                    color: isClicked == false ? Colors.blue : Colors.white,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          isClicked = false;
                        });
                        _googleSignIn.disconnect();
                        googleLogin();
                      },
                      // highlightElevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10.0, 10.0, 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            Image(
                                image: ExactAssetImage("images/g_logo_60.png"),
                                height: 35.0
                            ),

                               Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  "Sign in with Google",
                                  style: TextStyle(
                                    fontSize: 17.2,
                                    color: isClicked == false
                                        ? Colors.white
                                        : Colors.blue,
                                  ),

                            ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                ),
                SizedBox(height: 16),
                Container(
                  child: Text(
                    'Or',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black
                    ),
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isClicked = true;
                    });
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return RegisterScreen(
                        userId: widget.userId,
                        firstName: '',
                        lastName: '',
                        email: '',
                        token: this.widget.userToken,
                        auth: "",
                      );
                    },
                        settings: RouteSettings(
                          name: 'gmail_screen',
                        )
                    ));
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.80,
                      child: isClicked == false ?
                      Text(
                        "Sign in with Email",
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                      ) :
                      Card(
                        color: isClicked == false ? Colors.white : Colors.blue,
                        child: OutlinedButton(
                          // highlightElevation: 0,
                          onPressed: () {},
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                10.0, 10.0, 10.0, 14.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    "Sign in with Email",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: isClicked == false ?
                                        Colors.blue : Colors.white
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                  ),
                )
              ],
            ),
          ),

        )
    );
  }
}
