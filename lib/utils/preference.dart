import 'package:shared_preferences/shared_preferences.dart';

class Preference {
  static Future<SharedPreferences> get _instance async =>
      mSharedPrefs = await SharedPreferences.getInstance();
  static SharedPreferences? mSharedPrefs;

  static Future<SharedPreferences?> init() async {
    mSharedPrefs = await _instance;
    return mSharedPrefs;
  }

static String getUserId(String userId, [String? defValue]) {
return mSharedPrefs?.getString(userId) ?? defValue ?? "";

}

static Future<bool> setUserId(String userId, String value) async {
var prefs = await _instance;
return prefs.setString(userId, value);
}

static String getFirstName(String firstName, [String? defValue]) {
    return mSharedPrefs?.getString(firstName) ?? defValue ?? "";
}
static Future<bool> setFirstName(String firstName, String value) async {
    var prefs = await _instance;
    return prefs?.setString(firstName, value) ?? Future.value(false);
}

static String getAuthToken(String authToken, [String? defValue]) {
    return mSharedPrefs?.getString(authToken) ?? defValue ?? "";
}

static Future<bool> setAuthToken(String authToken, String value) async{
    var prefs = await _instance;
    return prefs?.setString(authToken, value) ?? Future.value(false);
}

  static String getLastName(String lastName, [String? defValue]) {
    return mSharedPrefs?.getString(lastName) ?? defValue ?? "";
  }

  static Future<bool> setLastName(String lastName, String value) async{
    var prefs = await _instance;
    return prefs?.setString(lastName, value) ?? Future.value(false) ;
  }

  static bool getEmailVerified(String emailVerified, [String? defValue]) {
    return mSharedPrefs?.getBool(emailVerified) ?? false;
  }

  static Future<bool> setEmailVerified(String emailVerified, bool value) async {
    var prefs = await _instance;
    return prefs.setBool(emailVerified, value) ?? Future.value(false);
  }

  static bool getMobileVerified(String mobileVerified, [String? defValue]) {
    return mSharedPrefs?.getBool(mobileVerified) ?? false;
  }

  static Future<bool> setMobileVerified(
      String mobileVerified, bool value) async {
    var prefs = await _instance;
    return prefs?.setBool(mobileVerified, value) ?? Future.value(false);
  }

  static String getMobileNumber(String mobileNumber, [String? defvalue]) {
    return mSharedPrefs?.getString(mobileNumber) ?? defvalue ?? "";
  }

  static Future<bool> setMobileNumber(String mobileNumber, String value) async {
    var prefs = await _instance;
    return prefs?.setString(mobileNumber, value) ?? Future.value(false);
  }

  static String getFirebaseToken(String firebaseToken, [String? defvalue]) {
    return mSharedPrefs?.getString(firebaseToken) ?? defvalue ?? "";
  }

  static Future<bool> setFirebaseToken(String firebaseToken, String value) async {
    var prefs = await _instance;
    return prefs?.setString(firebaseToken, value) ?? Future.value(false);
  }

  static String getEmail(String email, [String? defvalue]) {
    return mSharedPrefs?.getString(email) ?? defvalue ?? "";
  }

  static Future<bool> setEmail(String email, String value) async {
    var prefs = await _instance;
    return prefs?.setString(email, value) ?? Future.value(false);
  }

  static String getCourseId(String courseId, [String? defvalue]) {
    return mSharedPrefs?.getString(courseId) ?? defvalue ?? "";
  }

  static Future<bool> setCourseId(String courseId, String value) async {
    var prefs = await _instance;
    return prefs?.setString(courseId, value) ?? Future.value(false);
  }

  static String getCourseName(String courseName, [String? defvalue]) {
    return mSharedPrefs?.getString(courseName) ?? defvalue ?? "";
  }

  static Future<bool> setCourseName(String courseName, String value) async {
    var prefs = await _instance;
    return prefs?.setString(courseName, value) ?? Future.value(false);
  }

  static String getNotificationId(String notificationId, [String? defvalue]) {
    return mSharedPrefs?.getString(notificationId) ?? defvalue ?? "";
  }

  static Future<bool> setNotificationId(String notificationId, String value) async {
    var prefs = await _instance;
    return prefs?.setString(notificationId, value) ?? Future.value(false);
  }

}