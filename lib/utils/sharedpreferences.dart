import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  late SharedPreference preferences;
  final String auth_token ="auth_token";
  static final String user_id = "user_id";

  static Future<SharedPreferences> get _instance async =>
      _prefsInstance = await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  static Future<SharedPreferences?> init() async{
    _prefsInstance = await _instance;
    return _prefsInstance;
  }

  static String getString(user_id, user_idd){
    return _prefsInstance?.getString(user_id) ?? user_idd ?? "";

  }

  static Future<bool> setString(String key, String value) async {
    var prefs = await _instance;
    return prefs.setString(key, value) /*?? Future.value(false)*/;
  }

  Future<void> setAuthToken(String auth_token) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(this.auth_token, auth_token);

  }

  Future<String?> getAuthToken() async{
    final SharedPreferences pref =await SharedPreferences.getInstance();
    String? auth_token;
    auth_token = pref.getString(this.auth_token) ?? null;
    return auth_token;

  }

  Future<void> setUserId(String user_id) async{
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(user_id, user_id);
  }

  Future<String> getUserId() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(user_id) ?? user_id;
  }



}