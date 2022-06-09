import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:video_player/video_player.dart';
import 'cerificateclass.dart';
import 'utils/apiurl.dart';


class CourseVideoClass extends StatefulWidget {
  String courseTitle, videoThumb;
  String videoCompletion="";

  @override
  _CourseVideoClassState createState() => _CourseVideoClassState();
  CourseVideoClass({Key? key, required this.courseTitle,required this.videoThumb}) : super(key: key);
}

class _CourseVideoClassState extends State<CourseVideoClass> {

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  var videoList = [];
  var videoLogList = [];
  var videoComCheck = [];
  var nextVideoPlay = [];
  var currentItem;
  var videoTime;
  int videoCompletion = 0;
  int? videoTimer;
  Timer? timer;
  bool isLoading = false;
  bool certificateShow = false;
  double? unitHeightValue;
  String emptyCheck = "null";
  bool autoPlay = true;
  bool showWelcomeText = true;
  double minutes = 0.0;
  double hours = 0.0;
  double seconds = 0.0;
  bool isVideoClicked = false;

  @override
  void initState() {
    courseVideoList();
    super.initState();
  }


  Future<void> initializePlayer(
      int index,
      String url,
      String videoDuration,
      String videoId,
      String videoCompletion,
      int videoTimer,
      bool autoPlay) async {
    print('Video Timer: ' + videoTimer.toString());
    _videoPlayerController = VideoPlayerController.network(url);
    await Future.wait([
      _videoPlayerController!.initialize(),
    ]);
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        // allowFullScreen: true,
        showControlsOnInitialize: false,
        fullScreenByDefault: false,
        showControls: true,
        allowMuting: false,
        startAt: Duration(seconds: videoTimer),
        allowPlaybackSpeedChanging: true,
        aspectRatio: 16 / 9,
        autoPlay: autoPlay,
        looping: false,
        customControls: const CupertinoControls(backgroundColor: Colors.white10, iconColor: Colors.white)

    );
    timerCall(index, videoDuration, videoId, videoCompletion, videoTimer);
  }

  void timerCall(int index, String videoDuration, String videoId,
      String videoCompletion, int videoTimer) {
    if (!mounted) return;
    setState(() {
      if (_videoPlayerController!.value.position ==
          _videoPlayerController!.value.duration) {
        videoTimerUpdate(videoDuration, this.videoCompletion, videoId);
        print('Video End ' + videoCompletion.toString());
        timer!.cancel();

      }
    });
    timer = Timer.periodic(new Duration(seconds: 3), (timer) {
      print("TIMER SEQ: " + timer.tick.toString());
      print('Video Duration: ' +
          _videoPlayerController!.value.duration.toString());
      var splitDot =
      _videoPlayerController!.value.position.toString().split('.');
      print('Video Split Dot: ' + splitDot.toString());
      var splitColon = splitDot[0].split(':');
      print('Video Split Colon: ' + splitColon.toString());
      var pos1 = int.parse(splitColon[0]) * 60 * 60;
      var pos2 = int.parse(splitColon[1 /*0*/]) * 60;
      var pos3 = int.parse(splitColon[2/* 0*/]);
      var totalSeconds = pos1 + pos2 + pos3;
      print("totalSeconds: ${totalSeconds.toString()}");

      print('Video Id: ' + videoId);
      if (_videoPlayerController!.value.position ==
          _videoPlayerController!.value.duration) {
        index += 1;
        print('NEXT VID: ' + index.toString());
        this.videoCompletion = 1;
        videoTimerUpdate(
            totalSeconds.toString(), this.videoCompletion, videoId);
        print('Video Ended ' + videoCompletion.toString());
        timer.cancel();
      } else {
        if (videoCompletion == "true") {
          this.videoCompletion = 1;
        } else {
          this.videoCompletion = 0;
        }
        print('Video Playing ' + videoCompletion.toString());
      }

      print('Total: ' + totalSeconds.toString());

      if (!mounted) return;
      setState(() {
        if (_videoPlayerController!.value.isPlaying) {
          videoTimerUpdate(
              totalSeconds.toString(), this.videoCompletion, videoId);
          print('VIDEO: PLAY PAUSE: Video is Playing');
        } else {
          print('VIDEO: PLAY PAUSE: Video on Pause');
        }
      });
    });
  }

  void autoPlayback(int index) {
    courseVideoList();
    if (videoList.length > 1) {
      if (index == videoList.length - 1) {
        if ((videoList[index - 1]['video_completion'] == 'true')) {
          print('Play last index of the video');
          if ((videoList[index]['video_timer'] ==
              int.parse(videoList[index]['video_duration']))) {
            this.videoTimer = 0;
          } else {
            this.videoTimer = videoList[index]['video_timer'];
          }
          _chewieController = null;
          initializePlayer(
              index,
              /*"https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
              "52",*/
              videoList[index]['url'],
              videoList[index]['video_duration'],
              videoList[index]['coursevideo_id'],
              videoList[index]['video_completion'],
              this.videoTimer!,
              false);
        } else {
          Fluttertoast.showToast(msg:'Please complete the previous video',
              toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
          print('Cannot play ' + index.toString());
        }
        print('Index last ' + index.toString());
      } else {
        print('Index value ' + index.toString());
        print('Index ABC 1' + videoList[0]['video_completion']);
        print('Index ABC 2' + videoList[index]['video_completion']);
        print('Index ABC 3' + videoList[index].toString());
        if (index == 0) {

          if ((videoList[index]['video_timer'] ==
              int.parse(videoList[index]['video_duration']))) {
            this.videoTimer = 0;
          } else {
            this.videoTimer = videoList[index]['video_timer'];
          }
          _chewieController = null;
          initializePlayer(
              index,
               /*"https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
              "52",*/
              videoList[index]['url'],
              videoList[index]['video_duration'],
              videoList[index]['coursevideo_id'],
              videoList[index]['video_completion'],
              this.videoTimer!,
              false);
          print('Video: Play first index of the video only ' +
              index.toString() +
              " Video Timer: " +
              this.videoTimer.toString());
        } else if (videoList[index]['video_completion'] == "false") {
          print(
              'Video: Play false index of the video only ' + index.toString());

          if ((videoList[index]['video_timer'] ==
              int.parse(videoList[index]['video_duration']))) {
            this.videoTimer = 0;
          } else {
            this.videoTimer = videoList[index]['video_timer'];
          }
          _chewieController = null;
          initializePlayer(
              index,
              videoList[index]['url'],
              videoList[index]['video_duration'],
              /*"https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
              "52",*/
              videoList[index]['coursevideo_id'],
              videoList[index]['video_completion'],
              this.videoTimer!,
              false);
        } else if ((videoList[index]['video_completion'] == "true") &&
            (videoList[index + 1]['video_completion'] == "")) {
          print('Video: Play first/second index of the video ' +
              index.toString());
          if ((videoList[index]['video_timer'] ==
              int.parse(videoList[index]['video_duration']))) {
            this.videoTimer = 0;
          } else {
            this.videoTimer = videoList[index]['video_timer'];
          }
          _chewieController = null;
          initializePlayer(
              index,
              videoList[index]['url'],
              videoList[index]['video_duration'],
              /*"https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
              "52",*/
              videoList[index]['coursevideo_id'],
              videoList[index]['video_completion'],
              this.videoTimer!,
              false);
        } else if ((videoList[index]['video_completion'] == "true") ||
            (videoList[index + 1]['video_completion'] == "false")) {
          print('Video: Play first/second index of the video ' +
              index.toString());
          if ((videoList[index]['video_timer'] ==
              int.parse(videoList[index]['video_duration']))) {
            this.videoTimer = 0;
          } else {
            this.videoTimer = videoList[index]['video_timer'];
          }
          _chewieController = null;
          initializePlayer(
              index,
              videoList[index]['url'],
              videoList[index]['video_duration'],
              /*"https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
              "52",*/
              videoList[index]['coursevideo_id'],
              videoList[index]['video_completion'],
              this.videoTimer!,
              false);
        } else if ((videoList[index - 1]['video_completion'] == "true") &&
            (videoList[index]['video_completion'] == "")) {
          print('Video: Play first/second index of the video ' +
              index.toString());
          if ((videoList[index]['video_timer'] ==
              int.parse(videoList[index]['video_duration']))) {
            this.videoTimer = 0;
          } else {
            this.videoTimer = videoList[index]['video_timer'];
          }
          _chewieController = null;
          initializePlayer(
              index,
              videoList[index]['url'],
              videoList[index]['video_duration'],
              /*"https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
              "52",*/
              videoList[index]['coursevideo_id'],
              videoList[index]['video_completion'],
              this.videoTimer!,
              false);
        } else {
          print('Cannot play ' + index.toString());
          Fluttertoast.showToast(msg: 'Please complete the previous video',
              toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM);
        }
      }
    } else {
      print('Video Session: Else');
      print('Just play the video');
      if ((videoList[index]['video_timer'] ==
          int.parse(videoList[index]['video_duration']))) {
        this.videoTimer = 0;
      } else {
        this.videoTimer = videoList[index]['video_timer'];
      }
      _chewieController = null;
      initializePlayer(
          index,
          videoList[index]['url'],
          videoList[index]['video_duration'],
          /*"https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
          "52",*/
          videoList[index]['coursevideo_id'],
          videoList[index]['video_completion'],
          this.videoTimer!,
          false);
    }
  }

  Future<String?> videoTimerUpdate(
      String timing, int completed, String videoId) async {
    final response =
    await http.post(Uri.parse(ApiUrl.BASE_URL_Test1 + ApiUrl.COURSE_VIDEO_TRIMMER),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
        },
        body: jsonEncode({
          "course_id":
          Preference.getCourseId(
              Constants.COURSE_ID),
          "user_id": Preference.getUserId(Constants.USER_ID),
          "completed": completed,
          "timer": timing,
          "video_id": videoId
        }));
    print('Timer Completed' + completed.toString());
    print('Timer time' + timing.toString());
    print('Timer vID' + videoId);

    if (response.statusCode == 200) {
      var jsonData = json.decode(utf8.decode(response.bodyBytes));
      var data = jsonData['data'];
      print('TIMER UPDATE: ' + data.toString());
      print('USER ID: ' + Preference.getUserId(Constants.USER_ID));
    } else {
      print('USER ID: ' + Preference.getUserId(Constants.USER_ID));
      print('TIMER UPDATE: Exception');
      throw Exception('Failed to load');
    }
  }

  Future<String?> courseVideoList() async {

    videoList.clear();
    print('Notification');
    final response =
    await http.post(Uri.parse(ApiUrl.BASE_COURSE_URL + ApiUrl.COURSE_VIDEOS),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
        },
        body: jsonEncode(<String, String>{
          'couserId': Preference.getCourseId(Constants.COURSE_ID),
        }));
    print('CID ' + Preference.getCourseId(Constants.COURSE_ID));
    try {
      if (response.statusCode == 200) {
        isLoading = true;
        videoLog();
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data'];
        setState(() {
          videoList = data;
        });
        print("Video List-> " + videoList.toString());
        videoComCheck.clear();
        for (int i = 0; i < videoList.length; i++) {
          nextVideoPlay.add(videoList[i]['video_completion']);
          if (videoList[i]['video_completion'] == "") {
            print('Video is empty');
          } else if (videoList[i]['video_completion'] == "false") {
            print('Video is false');
          } else {
            print('Video is true');
          }

          if (videoList[i]['video_completion'] == "true") {
            videoComCheck.add(videoList[i]['video_completion']);
          } else {
            break;
          }
        }
        print('TRUE CHECK ' + videoComCheck.toString());
        if (videoList.isNotEmpty) {
          emptyCheck = 'true';
          if (videoList.length == videoComCheck.length) {
            print('Show Certificate');
            this.certificateShow = true;
          } else {
            this.certificateShow = false;
            print('Do not');
          }
        } else {
          emptyCheck = 'false';

        }

        print('Video List In TRY IF');
      } else {
        isLoading = true;
        print('Video List Error In TRY ELSE');
      }
    } catch (Exception) {
      isLoading = true;
      print('raiseConcernList Error in Catch');
      Fluttertoast.showToast(msg: 'Failed to load',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
      // throw Exception('Failed to load');
    }
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    _chewieController?.dispose();
    timer!.cancel();
    super.dispose();
  }

  showAlertDialog(BuildContext context) {

    Widget okButton = TextButton(
      child: Text("Okay"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      content: Text("No videos available"),
      actions: [
        okButton,
      ],
    );


    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<String?> videoLog() async {
    final response =
    await http.post(Uri.parse(ApiUrl.BASE_URL_Test1 + ApiUrl.COURSE_VIDEO_LOG),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
        },
        body: jsonEncode(<String, String>{
          "course_id": Preference.getCourseId(Constants.COURSE_ID),
        }));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data'];
      videoLogList = data;
      print('COURSE VIDEO LOG: ' + data.toString());
    } else {
      print('COURSE VIDEO LOG: Exception');
      throw Exception('Failed to load');
    }
  }

  Future<String?> freeCourseCompletion() async {
    final response =
    await http.post(Uri.parse(ApiUrl.BASE_URL_Test + ApiUrl.FREE_COURSE_COMPLETION),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
        },
        body: jsonEncode(<String, String>{
          "course_id": Preference.getCourseId(Constants.COURSE_ID),
          "user_id": Preference.getUserId(Constants.USER_ID),
          "completed": "1"
        }));
    print(Preference.getCourseId(Constants.COURSE_ID));
    print(Preference.getUserId(Constants.USER_ID));
    print(Preference.getAuthToken(Constants.AUTH_TOKEN));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data'];
      var imageURL = data['certificate_url'];


      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CertificationClass(
                imageURL:  imageURL)
        ),
      );
    } else {
      print(Exception("Failed to load"));
    }
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(

      centerTitle: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 30,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.arrow_back_ios),
              iconSize: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
    return Scaffold(
        body: Container(

          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage('images/courses_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(

                padding: EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.08,
                      child: new IconButton(
                        icon: new Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, top: 16, bottom: 5, right: 20),
                        child: RichText(
                          text: TextSpan(children: <TextSpan>[
                            TextSpan(
                              text: this.widget.courseTitle,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500),
                            ),
                            TextSpan(
                              text: videoList.length > 1
                                  ? "\n\n" + videoList.length.toString() +
                                  "-videos"
                                  : "\n\n" + videoList.length.toString() +
                                  "-video",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                child: Visibility(
                  visible: isVideoClicked,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height  * 0.25,
                    child: _chewieController != null &&
                        _chewieController!
                            .videoPlayerController.value.isInitialized
                        ? Chewie(
                      controller: _chewieController!,
                    )
                        : showWelcomeText == true
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Flexible(
                          child: CachedNetworkImage(
                            imageUrl: this.widget.videoThumb,
                            fit: BoxFit.fill,
                            errorWidget: (context,url,error) => Image.asset('images/no_image.png'),
                          ),
                        ),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(
                          backgroundColor: Colors.white54,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Loading',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ClipRect(
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    child: emptyCheck == 'true'
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(3),
                            itemCount:
                            (videoList == null) ? 0 : videoList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {});
                                  if (videoList.length > 1) {
                                    print('Video Session: If');
                                    print('Index value If ' + index.toString());
                                    print('Index value If Len' +
                                        videoList.length.toString());
                                    if (index == videoList.length - 1) {
                                      if ((videoList[index - 1]
                                      ['video_completion'] == 'true')) {
                                        isVideoClicked = true;
                                        print(
                                            'Play last index of the video');
                                        if ((videoList[index]
                                        ['video_timer'] ==
                                            int.parse(videoList[index]
                                            ['video_duration']))) {
                                          this.videoTimer = 0;
                                        } else {
                                          this.videoTimer = videoList[index]
                                          ['video_timer'];
                                        }
                                        _chewieController = null;
                                        showWelcomeText = false;
                                        initializePlayer(
                                            index,
                                            videoList[index]['url'],
                                            videoList[index]['video_duration'],
                                            /*"https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
                                            "52",*/
                                            videoList[index]
                                            ['coursevideo_id'],
                                            videoList[index]
                                            ['video_completion'],
                                            this.videoTimer!,
                                            true);
                                      } else {
                                        Fluttertoast.showToast(msg:
                                        'Please complete the previous video',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM);
                                        print('Cannot play ' +
                                            index.toString());
                                      }
                                      print(
                                          'Index last ' + index.toString());
                                    } else {
                                      print('Index value ' + index.toString());
                                      print('Index ABC 1' + videoList[0]['video_completion']);
                                      print('Index ABC 2' + videoList[index]['video_completion']);
                                      print('Index ABC 3' + videoList[index].toString());
                                      if (index == 0) {
                                        if ((videoList[index]
                                        ['video_timer'] ==
                                            int.parse(videoList[index]['video_duration']))) {
                                          this.videoTimer = 0;
                                        } else {
                                          this.videoTimer = videoList[index]['video_timer'];
                                        }
                                        _chewieController = null;
                                        showWelcomeText = false;
                                        initializePlayer(
                                            index,
                                            videoList[index]['url'],
                                            videoList[index]
                                            ['video_duration'],
                                            /*"https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
                                            "52",*/
                                            videoList[index]
                                            ['coursevideo_id'],
                                            videoList[index]
                                            ['video_completion'],
                                            this.videoTimer!,
                                            true);
                                        isVideoClicked = true;
                                        print(
                                            'Video: Play first index of the video only ' + index.toString() +
                                                " Video Timer: " +
                                                this.videoTimer.toString());
                                      } else if (videoList[index]
                                      ['video_completion'] ==
                                          "false") {
                                        print(
                                            'Video: Play false index of the video only ' + index.toString());
                                        if ((videoList[index]
                                        ['video_timer'] ==
                                            int.parse(videoList[index]['video_duration']))) {
                                          this.videoTimer = 0;
                                        } else {
                                          this.videoTimer = videoList[index]['video_timer'];
                                        }
                                        _chewieController = null;
                                        showWelcomeText = false;
                                        initializePlayer(
                                            index,
                                            videoList[index]['url'],
                                            videoList[index]
                                            ['video_duration'],
                                            /*"https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
                                            "52",*/
                                            videoList[index]
                                            ['coursevideo_id'],
                                            videoList[index]
                                            ['video_completion'],
                                            this.videoTimer!,
                                            true);
                                        isVideoClicked = true;
                                      } else if ((videoList[index]
                                      ['video_completion'] == "true") &&
                                          (videoList[index + 1]['video_completion'] ==
                                              "")) {
                                        print(
                                            'Video: Play first/second index of the video ' + index.toString());
                                        if ((videoList[index]
                                        ['video_timer'] ==
                                            int.parse(videoList[index]
                                            ['video_duration']))) {
                                          this.videoTimer = 0;
                                        } else {
                                          this.videoTimer = videoList[index]
                                          ['video_timer'];
                                        }
                                        _chewieController = null;
                                        showWelcomeText = false;
                                        initializePlayer(
                                            index,
                                            videoList[index]['url'],
                                            videoList[index]
                                            ['video_duration'],
                                            /*"https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
                                            "52",*/
                                            videoList[index]
                                            ['coursevideo_id'],
                                            videoList[index]
                                            ['video_completion'],
                                            this.videoTimer!,
                                            true);
                                        isVideoClicked = true;
                                      } else if ((videoList[index]
                                      ['video_completion'] ==
                                          "true") ||
                                          (videoList[index + 1]
                                          ['video_completion'] ==
                                              "false")) {
                                        print(
                                            'Video: Play first/second index of the video ' + index.toString());
                                        if ((videoList[index]
                                        ['video_timer'] ==
                                            int.parse(videoList[index]
                                            ['video_duration']))) {
                                          this.videoTimer = 0;
                                        } else {
                                          this.videoTimer = videoList[index]
                                          ['video_timer'];
                                        }
                                        _chewieController = null;
                                        showWelcomeText = false;
                                        initializePlayer(
                                            index,
                                            videoList[index]['url'],
                                            videoList[index]
                                            ['video_duration'],
                                            /*"https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
                                            "52",*/
                                            videoList[index]
                                            ['coursevideo_id'],
                                            videoList[index]
                                            ['video_completion'],
                                            this.videoTimer!,
                                            true);
                                        isVideoClicked = true;
                                      } else if ((videoList[index - 1]
                                      ['video_completion'] ==
                                          "true") &&
                                          (videoList[index]
                                          ['video_completion'] ==
                                              "")) {
                                        print(
                                            'Video: Play first/second index of the video ' +
                                                index.toString());
                                        if ((videoList[index]
                                        ['video_timer'] ==
                                            int.parse(videoList[index]
                                            ['video_duration']))) {
                                          this.videoTimer = 0;
                                        } else {
                                          this.videoTimer = videoList[index]
                                          ['video_timer'];
                                        }
                                        _chewieController = null;
                                        showWelcomeText = false;
                                        initializePlayer(
                                            index,
                                            /*videoList[index]['url'],
                                            videoList[index]
                                            ['video_duration'],*/
                                            "https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
                                            "52",
                                            videoList[index]
                                            ['coursevideo_id'],
                                            videoList[index]
                                            ['video_completion'],
                                            this.videoTimer!,
                                            true);
                                        isVideoClicked = true;
                                      } else {
                                        print('Cannot play ' +
                                            index.toString());
                                        Fluttertoast.showToast(msg:
                                        'Please complete the previous video',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM);
                                      }
                                    }
                                  } else {
                                    print('Video Session: Else');
                                    print('Just play the video');
                                    if ((videoList[index]['video_timer'] ==
                                        int.parse(videoList[index]
                                        ['video_duration']))) {
                                      this.videoTimer = 0;
                                    } else {
                                      this.videoTimer =
                                      videoList[index]['video_timer'];
                                    }
                                    _chewieController = null;
                                    showWelcomeText = false;
                                    initializePlayer(
                                        index,
                                        videoList[index]['url'],
                                        videoList[index]['video_duration'],
                                        /*"https://www.appsloveworld.com/wp-content/uploads/2018/10/640.mp4",
                                        "52",*/
                                        videoList[index]['coursevideo_id'],
                                        videoList[index]
                                        ['video_completion'],
                                        this.videoTimer!,
                                        true);
                                    isVideoClicked = true;
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 3.0,
                                  ),
                                  child: isLoading
                                      ? Card(
                                    elevation: 3.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(5.0),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          Container(
                                            height:
                                            MediaQuery.of(context).size.height * 0.10,
                                            width:
                                            MediaQuery.of(context).size.width * 0.15,
                                            child: Icon(
                                              Icons.play_circle_outline,
                                              color: Colors.black54,
                                              size: 50.0,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                MergeSemantics(
                                                  child: Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          videoList[index]['video_title'],
                                                          maxLines: 2,
                                                          overflow:
                                                          TextOverflow.ellipsis,
                                                          softWrap: true,
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w600,
                                                              color: Theme.of(context).primaryColor),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text((() {
                                                  if (double.parse(videoList[index]
                                                  ['video_duration']) > 59) {
                                                    minutes = double.parse(videoList[index]
                                                    ['video_duration']) / 60;
                                                    if (minutes > 59) {
                                                      hours = minutes / 60;
                                                      print(hours.toStringAsFixed(2) + ' hr');
                                                      return hours.toStringAsFixed(2) + ' hr';
                                                    } else {

                                                      print(minutes.toStringAsFixed(1) + ' min');
                                                      return minutes.toStringAsFixed(1) + ' min';
                                                    }
                                                  } else {
                                                    seconds = double.parse(videoList[index]['video_duration']);
                                                    print(seconds.ceil().toString() + ' sec');
                                                    return seconds.ceil().toString() + ' sec';
                                                  }
                                                })()),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                right: 8.0),
                                            child:
                                            CircularPercentIndicator(
                                              radius: 35.0,
                                              lineWidth: 3.0,
                                              percent: double.parse(
                                                  videoList[index]
                                                  ['video_percentage']) / 100,
                                              center: Padding(
                                                padding:
                                                const EdgeInsets
                                                    .all(5.0),
                                                child: new Text(
                                                  videoList[index][
                                                  'video_percentage'] +
                                                      "%",
                                                  style: TextStyle(
                                                      fontSize: 8),
                                                  textAlign: TextAlign.center,
                                                ),

                                              ),
                                              progressColor: int.parse(
                                                  videoList[index]['video_percentage']) == 0
                                                  ? Colors.grey
                                                  : int.parse(videoList[index]['video_percentage']) < 25
                                                  ? Colors.red
                                                  : int.parse(videoList[index]['video_percentage']) < 70
                                                  ? Colors.orange
                                                  : Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                      : Container(
                                      child: Center(
                                          child:
                                          CircularProgressIndicator())),
                                ),
                              );
                            },
                          ),
                        ),
                        // ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (this.certificateShow) {
                                freeCourseCompletion();
                              } else {
                                Fluttertoast.showToast(msg:
                                'Please complete video..',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM);
                              }
                            });
                          },
                          child: Card(
                            margin: EdgeInsets.only(
                                left: 27, right: 27, bottom: 15),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            color: Colors.blue,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: Icon(
                                      certificateShow
                                          ? Icons.lock_open
                                          : Icons.lock,
                                      color: Colors.white,
                                      size: 18.0,
                                    ),
                                  ),
                                  SizedBox(width: 10),

                                  Text(
                                    'VIEW CERTIFICATE',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                        : emptyCheck == 'false'
                        ?
                    Container(
                      alignment: Alignment.center,
                      child: Center(
                          child: Text(
                            'No videos available',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600),
                          )),
                      //),
                    )
                        :
                    Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    //),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
