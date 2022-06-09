import 'dart:convert';

import 'package:fita_app/utils/apiUrl.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;

class CoursePayment extends StatefulWidget {
  String courseFee, orderId, enrollmentModeId;
      var scheduleId, branchId;
   CoursePayment({Key? key,
   required this.courseFee,
   required this.orderId,
   required this.enrollmentModeId,
   required this.scheduleId,
   required this.branchId})
       :super(key: key);

  @override
  _CoursePaymentState createState() => _CoursePaymentState();
}

class _CoursePaymentState extends State<CoursePayment> {
  Razorpay? _razorpay;
  bool isPaymentSuccess = false;
  String signature = '', paymentId = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    openCheckout();
  }
  
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay!.clear();
  }
  
  Future<String?> paymentCallback() async {
    
    final response = await http.post(Uri.parse(ApiUrl.BASE_COURSE_URL + ApiUrl.PAYMENT_CALLBACK),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': Preference.getAuthToken(Constants.AUTH_TOKEN),
    },
    body: jsonEncode(<String,String>{
      "order_id": this.widget.orderId,
      "payment_id": paymentId,
      "signature" : signature,
      "coursefee" : this.widget.courseFee,
      "course_id" : Preference.getCourseId(Constants.COURSE_ID),
      "mode_id"   : this.widget.enrollmentModeId,
      "branchid"  : this.widget.branchId,
      "schedule_id" : this.widget.scheduleId
    }));

    if(response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      print('RETURN RES 200 ${jsonData.toString()}');
      showAlertDialog(context, "Payment done succeefully");
      setState(() {});
    } else {
      var jsonDataError = jsonDecode(response.body);
      print('RETURN RES ${jsonDataError.toString()}');
      showAlertDialog(context, jsonDataError['status']['message']);
      throw Exception('Failed to load');
    }
  }

  showAlertDialog(BuildContext context, String text) {

    Widget okButton = TextButton(
        onPressed: (){
          Navigator.pop(context);
        },
        child: Text("Okay")
    );

    AlertDialog alert = AlertDialog(
      content: Text(text),
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

  void openCheckout() async {
    var options = {
      'key' : Constants.PAYMENT_KEY_ID,
      'amount': int.parse(this.widget.courseFee),
      'name' : 'FITA ACADAMEY',
      'order_id' : this.widget.orderId,
      'retry' : {'enabled' : true, 'max_count' : 1},
      'send_sms_hash': true,
      'prefill' : {
        'contact' : Preference.getMobileNumber(Constants.MOBILE_NUMBER),
        'email' : Preference.getEmail(Constants.EMAIL)
      },
      'external' : {
        'wallets' : ['paytm']
      }
    };

    try {
      _razorpay!.open(options);
      print('Razor pay try: ');
    } catch (e) {
      debugPrint('Error: e');
      print('Razor pay catch: ' + e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    isPaymentSuccess = true;
    print('FITA DONE: ${response.toString()}');
    print('FITA DONE SIGNATURE: ${response.signature.toString()}');
    print('FITA DONE PAYMENT ID: ${response.paymentId.toString()}');
    paymentId = response.paymentId.toString();
    signature = response.signature.toString();
    paymentCallback();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isPaymentSuccess = false;
    print("FITA UNDONE: ${response.toString()}");

  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('EXTERNAL: ${response.toString()}');
  }

  @override
  Widget build(BuildContext context) {

    return Container();
  }
}
