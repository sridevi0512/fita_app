import 'package:first_app/tabpages/tabNavigator.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';



class HomePage extends StatefulWidget {
  int receiveCourseIdentity;


  @override
  _HomePageState createState() => _HomePageState();
   HomePage({Key? key,
     required this.receiveCourseIdentity})
       : super(key: key);
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _currentPage = "Home";
  List<String> pageKeys = ["Home", "My Course", "Profile", "Notification"];
  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "Home": GlobalKey<NavigatorState>(),
    "My Course": GlobalKey<NavigatorState>(),
    "Profile": GlobalKey<NavigatorState>(),
    "Notification": GlobalKey<NavigatorState>(),
  };
  @override
  void initState() {
    super.initState();

  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem]!,
        tabItem: tabItem,
      ),
    );
  }

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
        _selectedIndex = index;
      });
    }
  }
  List<Widget> _widgetOptions = <Widget>[



  ];

  void _onItemTapped(int index) {
    setState(() {
      this.widget.receiveCourseIdentity = index;
    });
  }

  @override
  Widget build(BuildContext context) {
   /* _widgetOptions = [
      _buildOffstageNavigator("Home"),
      _buildOffstageNavigator("My Course"),
      _buildOffstageNavigator("Profile"),
      _buildOffstageNavigator("Notification"),
    ];*/

    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentPage]!.currentState!.maybePop();
        print("isFirstRouteInCurrentTab ${isFirstRouteInCurrentTab}");
        print("currentpage ${_currentPage}");
        if (isFirstRouteInCurrentTab) {
          if (_currentPage != "Home") {
            _selectTab("Home", 0);
            _selectTab("My Course", 1);
            _selectTab("Profile", 2);
            _selectTab("Notification", 3);
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(

        body: /*_widgetOptions[_selectedIndex],*/
        LazyLoadIndexedStack(
          index: _selectedIndex,
          children:  [
            _buildOffstageNavigator("Home"),
            _buildOffstageNavigator("My Course"),
            _buildOffstageNavigator("Profile"),
            _buildOffstageNavigator("Notification"),
          ],
        ),
/*        Stack(children: <Widget>[
          _buildOffstageNavigator("Home"),
          _buildOffstageNavigator("My Course"),
          _buildOffstageNavigator("Profile"),
          _buildOffstageNavigator("Notification"),
        ],
        ),*/
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blueAccent,
          onTap: (int index) {
            _selectTab(pageKeys[index], index);
          },
          currentIndex: _selectedIndex,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.video_library_outlined),
              label: 'My Course',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.account_circle_outlined),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.notifications_outlined),
              label: 'Notification',
            ),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

/*class HomeScreenTabBar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(child: Text("HOME SCREEN")
      ),
    );
  }

} */

/*class ProfileScreenTabBar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      child: Center(child: Text("PROFILE SCREEN")
      ),
    );
  }
}*/



  
/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child:AppBar(
          backgroundColor: Colors.white,
          centerTitle: false,
          title:
              Padding(padding: EdgeInsets.all(8.0),
              child: Image.asset('images/logo.jpg', fit: BoxFit.fill),),





          actions: [
            new Padding(padding: EdgeInsets.all(8.0),
              child: Container(
                height: 40,
                width: 40,
                child: GestureDetector(
                  onTap: (){

                  },
                  child: Stack(
                    children: [
                      new IconButton(onPressed: (){},
                          icon: new Icon(Icons.notifications, color: Colors.blue,size: 30,),
                          tooltip: 'Notification'),
                      Positioned(right: 0.0,
                          child: Stack(
                            children: [
                              new Icon(Icons.brightness_1,size: 20.0, color: Colors.red),
                              new Positioned(top:4.0,
                                  right:5.0,
                                  child:new Text(
                                    "",
                                    style: new TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11.0,
                                        color: Colors.white
                                    ),
                                  ) )
                            ],
                          ))
                    ],
                  ),
                ),
              ),),
            Padding(padding: EdgeInsets.all(3.0),
            child: RawMaterialButton(onPressed: (){},
              elevation: 2.0,
              fillColor: Colors.blue,
              child: IconButton(onPressed: (){
                showPopupMenu();
              },
                  icon: new FaIcon(FontAwesomeIcons.userGraduate),
                  tooltip: 'application'),
              shape: CircleBorder(),
              padding: EdgeInsets.all(5.0),)
              ,)

          ],
        ),

      ),

      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child:ElevatedButton(onPressed: (){}, child: Text(
                  "Take Quick Assessment",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white

                  )
              ),style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  minimumSize: const Size(350, 90),
                  maximumSize: const Size(350, 90),
                  */
/*padding: EdgeInsets.symmetric(horizontal: 50, vertical: 35),*//*

                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(50.0),
                  )
              ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "Find your Goal in less than 3 minutes",
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child:ElevatedButton(onPressed: (){}, child: Text(
                  "Explore Courses",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white

                  )
              ),style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  minimumSize: const Size(350, 90),
                  maximumSize: const Size(350, 90),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(50.0),
                  )
              ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "I am clear with my Goal",
                style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child:ElevatedButton(onPressed: (){}, child: Text(
                  "Explore Free Courses",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white

                  )
              ),style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  minimumSize: const Size(350, 90),
                  maximumSize: const Size(350, 90),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(50.0),
                  )
              ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  showPopupMenu(){
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(25.0, 25.0, 0.0, 0.0),
      items: [
        PopupMenuItem<String>(
            child: const Text('My Certificate',style: TextStyle(fontWeight: FontWeight.w600),), value: '1'),
        PopupMenuItem<String>(
            child: const Text('My Courses',style: TextStyle(fontWeight: FontWeight.w600), ),value: '2'),
        PopupMenuItem<String>(
            child: const Text('Edit Profile',style: TextStyle(fontWeight: FontWeight.w600)), value: '3'),
        PopupMenuItem<String>(
          child: const Text('Logout',style: TextStyle(fontWeight: FontWeight.w600)), value: '4'
        ),
      ],
      elevation: 8.0,
    ).then<void>((String? itemSelected) {

      if (itemSelected == null) return;

      if(itemSelected == "1"){
        //code here
      }else if(itemSelected == "2"){
        //code here
      }else if(itemSelected == "3"){

      }
      else if(itemSelected == "4"){
        logoutUser();
      }
      else{
        //code here
      }

    });
  }
  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('mobilenumber');
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
            MyApp()),


    );
  }
  */

