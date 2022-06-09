import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Future<Album>? futureAlbum;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureAlbum = createAlbum("9841890183", "user");
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: Scaffold(
        body: Center(
          child: FutureBuilder<Album>(
            future: futureAlbum,
            builder: (context,snapshot) {
              if(snapshot.hasData){
                print(snapshot.data!.title);
                } else if(snapshot.hasError){
                print(snapshot.hasError);
                return Text("${snapshot.error}" + snapshot.toString());
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

Future<Album> fetchAlbum() async{
  print("fetchAlbum");
  final response = await http.get(Uri.parse('https://fita.sitecare.org/api/users/mobile-login'));
  if(response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load Album a');
  }
}

Future<Album> createAlbum(String number, String role) async{
  print(number);

  final response = await http.post(
    Uri.parse('https://fita.sitecare.org/api/users/mobile-login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String,String>{
      'mobile_number' : number,
      'role' : role,
    })
  );

  var responseData = json.decode(response.body);
  print(responseData);
  print(response);

  if(response.statusCode == 201){
    return Album.fromJson(jsonDecode(response.body));
  }else {
    throw Exception('Failed to load album');
  }

}

class Album {
  final int userId;
  final int id;
  final String title;

  Album({required this.userId,required this.id,required this.title});

  factory Album.fromJson(Map<String,dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}
