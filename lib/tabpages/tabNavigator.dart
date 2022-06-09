import 'package:fita_app/tabpages/assessmentlaunch.dart';
import 'package:fita_app/tabpages/notificationpage.dart';
import 'package:fita_app/tabpages/profilepage.dart';
import 'package:fita_app/utils/constants.dart';
import 'package:fita_app/utils/preference.dart';
import 'package:flutter/material.dart';

import 'myCourse.dart';
class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}
class TabNavigator extends StatelessWidget {
  TabNavigator({required this.navigatorKey, required this.tabItem});

  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;


  @override
  Widget build(BuildContext context) {
   late  Widget child;
    if (tabItem == "Home") {
      child = AssessmentLaunch(
        token: Preference.getAuthToken(Constants.AUTH_TOKEN),
      );
    } else if (tabItem == "My Course") {
      child = MyCourse();
    } else if (tabItem == "Profile") {
      child = MyProfile();
    } else if (tabItem == "Notification") {
      child = NotificationClass();
    }

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          settings: routeSettings,
            builder: (context) => child);
      },
    );
  }
}