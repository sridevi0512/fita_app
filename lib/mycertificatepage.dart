import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:device_info/device_info.dart';
import 'package:external_path/external_path.dart';
import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:isolated_worker/isolated_worker.dart';
import 'package:isolated_worker/js_isolated_worker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:share_plus/share_plus.dart';

class MyCertificate extends StatefulWidget {
  const MyCertificate({Key? key}) : super(key: key);

  @override
  _MyCertificateState createState() => _MyCertificateState();
}

class _MyCertificateState extends State<MyCertificate> {
  List certificateList = [];
  String selectedValue = "";
  String path = '';
  String isLoaded = 'null';
  ReceivePort _port = ReceivePort();
  bool isCalled = false;
  bool downloading = true;
  String downloadingStr = "No data";
  List<String> imagePaths = [];
  List<String> _list = [
    "Concern Status",
    "Raise Concern",
    "My Certificate",
    "Feedback"
  ];

  List<String> iconImages = [
    "images/concern_status.png",
    "images/concern_raise.png",
    "images/certificate.png",
    "images/feedback_icon.png"
  ];

  Future<String?> myCertificates() async {
    final response = await http.get(Uri.parse(
        ApiUrl.BASE_COURSE_URL + ApiUrl.CERTIFICATE_LIST),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
      },

    );
    var jsonData = jsonDecode(response.body);
    try{
      if(response.statusCode == 200) {
        isLoaded = "true";
        isCalled = true;
        var data = jsonData['data']['enrollcoursedata'];
        certificateList = data;
        print(data.toString());
        setState(() {});
      } else {
        isLoaded = 'false';
        print('Cert Error In TRY ELSE');
      }
    } catch (Exception) {
      var data1 = jsonData.toString();
      print("CERTIFICATE ELSE ${data1.toString()}");
      print("catch Error");
      Fluttertoast.showToast(msg: "Failed to load",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }
  getTask(){
    if(kIsWeb){

    }else{
      IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
      _port.listen((dynamic data) {
        String id = data[0];
        DownloadTaskStatus status = data[1];
        int progress = data[2];
        setState((){ });
      });
      // if(FlutterDownloader.registerCallback(downloadCallback) !=null){
        FlutterDownloader.registerCallback(downloadCallback);
      // }


    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myCertificates();
    getTask();



  }
  @override
  void dispose() {
    // TODO: implement dispose
    getDispose();
    super.dispose();
  }
   static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    if(kIsWeb){

    }else{
      final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
      send.send([id, status, progress]);
    }

  }
  getDispose(){
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Certificates'),
        actions: [],
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/courses_bg.png'),
                fit: BoxFit.cover
            )
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 12, left: 8,right: 8,bottom: 12),
          child: isLoaded == "true"
              ? Column(
            children: [
              Expanded(
                  child: GridView.count(
                      crossAxisCount: 1,
                      childAspectRatio: (16/14),
                      children:
                      List.generate(certificateList.length, (index) {
                        return GestureDetector(
                          onTap: (){
                            setState(() {});
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Visibility(
                                    visible: isCalled,
                                    child: Card(
                                      elevation: 3.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),

                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(0),
                                          child: Column(
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                child: CachedNetworkImage(
                                                  imageUrl: certificateList[index]['certificate_url'],
                                                  fit: BoxFit.fitWidth,
                                                  placeholder: (context,url) => Container(),
                                                  errorWidget: (context,url,error) => Container(),
                                                ),
                                              ),
                                              Container(
                                                alignment: Alignment.topLeft,
                                                child: Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Text(
                                                    certificateList[index]['course'],
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    softWrap: true,
                                                    maxLines: 2,
                                                    textAlign: TextAlign.start,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )

                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: EdgeInsets.only(left:3),
                                      child:PopupMenuButton(
                                        elevation: 20,
                                        onSelected: (value) async {
                                          if(value == 1) {
                                            if(Platform.isAndroid) {
                                              path = await ExternalPath.getExternalStoragePublicDirectory(
                                                  ExternalPath.DIRECTORY_DOWNLOADS);
                                              print(path);
                                            } else if(Platform.isIOS) {
                                              Directory documents = await getApplicationDocumentsDirectory();
                                              path = documents.path;
                                            }
                                            final savedDir = Directory(path);
                                            bool hasExisted = await savedDir.exists();
                                            if(!hasExisted) {
                                              savedDir.create();
                                            }
                                            Directory tempDir = await getTemporaryDirectory();
                                            String tempPath = tempDir.path;
                                            Fluttertoast.showToast(
                                                msg: "Downloading process is happening in the background. You can see that in the mobile Notification Bar." ,
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.grey[600],
                                                textColor: Colors.white,
                                                fontSize: 16.0
                                            );
                                            if(Platform.isIOS){

                                            } else if(Platform.isAndroid){
                                              print("path");
                                              print(path);
                                              final status = (await Permission.storage.request());

                                              if(status.isGranted) {
                                                final externalDir = await getExternalStorageDirectory();
                                                print("ExternalDir.${externalDir}");
                                                bool hasExisted = await externalDir!.exists();
                                                if(!hasExisted) {
                                                  print("create");
                                                  externalDir.create();
                                                }
                                                /*Dio dio = Dio();
                                              final taskId = await dio.download(certificateList[index]['certificate_url'],
                                                  externalDir!.path,
                                                onReceiveProgress: (rec,total){
                                                setState(() {
                                                  downloading = true;
                                                  downloadingStr = "Downloading Image : $rec" ;
                                                });
                                                });
                                              setState(() {
                                                downloading = false;
                                                downloadingStr = "Completed";
                                              });*/
                                                final taskId = await FlutterDownloader.enqueue(
                                                    url: certificateList[index]['certificate_url'],
                                                    fileName: certificateList[index]['course'] + '.png',
                                                    savedDir: externalDir.path,
                                                    showNotification: true,
                                                    openFileFromNotification: true,
                                                    saveInPublicStorage: true
                                                );
                                                print("taskId: ${taskId}");
                                                FlutterDownloader.open(taskId: taskId!);
                                              }
                                              else{
                                                print('Permission Denied');
                                              }

                                            }
                                            if(Platform.isIOS) {

                                            }

                                          } else {
                                            try {
                                              var url = certificateList[index]['certificate_url'];
                                              print(url);
                                              var response = await get(Uri.parse(url));
                                              print(url);
                                              final Directory documentDirectory = await getTemporaryDirectory();
                                              print("documentDirectory ${documentDirectory.path}");
                                              File imgFile = new File(documentDirectory.path +
                                                  '/flutter.png');
                                              print("imgFile ${imgFile}");
                                              imgFile.writeAsBytesSync(response.bodyBytes);
                                              print(documentDirectory);
                                              imagePaths.add(documentDirectory.path + '/flutter.png');
                                              // await Share.shareFiles(imagePaths);
                                            }catch(Exception){
                                              print(Exception);
                                            }
                                          }
                                          setState(()  {});
                                        },
                                        shape: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 1
                                            )
                                        ),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            child: Text('Download'),
                                            value: 1,
                                          ),
                                          PopupMenuItem(
                                            child: Text('Share'),
                                            value: 2,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      })
                  ))
            ],
          ) : isLoaded == "false"?
          Container(
            alignment: Alignment.center,
            child: Center(
              child: Text(
                "No certificate available",
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600
                ),
              ),
            ),
          ):
          Container(
            alignment: Alignment.center,
            child: Center(
              child: Text(
                "No certificate available",
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
