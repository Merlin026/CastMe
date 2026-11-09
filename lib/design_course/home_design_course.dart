import 'package:castme/ActorEventCalendarScreen.dart';
import 'package:castme/ActorViewHirings.dart';
import 'package:castme/ActorViewMentorVideos.dart';
import 'package:castme/ActorViewMyApplication.dart';
import 'package:castme/ActorViewVecancymages.dart';
import 'package:castme/ActorendComplaints.dart';
import 'package:castme/ActorsChatBox.dart';
import 'package:castme/CreateGroupPage.dart';
import 'package:castme/EventCalendarScreen.dart';
import 'package:castme/GroupChatPeoplesSelection.dart';
import 'package:castme/HomePage.dart';
import 'package:castme/PortfolioCreationPage.dart';
import 'package:castme/ProfilePage.dart';
import 'package:castme/UserViewBookings.dart';
import 'package:castme/UserViewImagesnadvideos.dart';
import 'package:castme/UserViewseminar.dart';
import 'package:castme/ViewPortfolioPage.dart';
import 'package:castme/design_course/category_list_view.dart';
import 'package:castme/design_course/design_course_app_theme.dart';
import 'package:castme/design_course/popular_course_list_view.dart';
import 'package:castme/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import '../GroupChatBox.dart';

class DesignCourseHomeScreen extends StatefulWidget {
  @override
  _DesignCourseHomeScreenState createState() => _DesignCourseHomeScreenState();
}

class _DesignCourseHomeScreenState extends State<DesignCourseHomeScreen> {
  String? firstName;
  String? photoUrl;
  String baseUrl = ''; // Declare baseUrl as an empty string initially
  List<Map<String, dynamic>> driverData = [];

  @override
  void initState() {
    super.initState();
    getData(); // Fetch user data when the screen is loaded
  }

  // Function to get data from API
  Future<void> getData() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? '';
      String lid = sh.getString("lid") ?? '';

      // Update the baseUrl with the fetched IP address dynamically
      baseUrl = ip.toString();

      final response = await http.post(
        Uri.parse("$baseUrl/api/View_myprofile"),
        body: {'lid': lid}, // Add lid to the request body
      );

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
              jsonDecode(response.body)['data']);
          setState(() {
            driverData = data;
            if (driverData.isNotEmpty) {
              firstName = driverData[0]['first_name'];
              photoUrl = baseUrl + "/" + driverData[0]['photo'];
            }
          });
        } else {
          Fluttertoast.showToast(
            msg: "Failed: No data",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Returning false to prevent back navigation
        return false;
      },
      child: Container(
        color: DesignCourseAppTheme.nearlyWhite,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Design Courses'),
            backgroundColor: Colors.black, // Set the background color to black
          ),
          drawer: Drawer(
            width: 200,
            child: SingleChildScrollView(  // Add this widget for scrolling
              child: Column(
                children: [
                  Container(
                    height: 95,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Center(
                        child: Text(
                          'Cast Me',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => DesignCourseHomeScreen()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.precision_manufacturing),
                    title: Text('Mentorship'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ActorViewMentorVideos()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.call),
                    title: Text('Casting Calls'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => UserViewProduct()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings_applications),
                    title: Text('Applications'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ViewMyApplication()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.airplane_ticket),
                    title: Text('Workshop Bookings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => UserViewbpooking()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.note_add),
                    title: Text('Workshop'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => UserViewseminar()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.surround_sound),
                    title: Text('Hirings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ActorViewHirings()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.book),
                    title: Text('Complaints'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ActorendComplaints()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Text('Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ViewPortfolioPage()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.event),
                    title: Text('Calendar'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ActorEventCalendarScreen()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.message),
                    title: Text('Chat'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => CareerGuidanceChatBox()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text('Sign Out'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => LoginPage()));
                    },
                  ),
                ],
              ),
            ),
          ),

            body: Column(
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).padding.top),
              getAppBarUI(),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: <Widget>[
                        getCategoryUI(),
                        Flexible(child: getPopularCourseUI()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getAppBarUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18, right: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Row for "Welcome Back" and user name text
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Welcome Back',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              letterSpacing: 0.2,
                              color: DesignCourseAppTheme.grey,
                            ),
                          ),
                          Text(
                            firstName ?? 'User',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              letterSpacing: 0.27,
                              color: DesignCourseAppTheme.darkerText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile Image
                    if (photoUrl != null)
                      Container(
                        width: 60,
                        height: 60,
                        child: ClipOval(
                          child: Image.network(
                            photoUrl!,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10), // Space between image and button
                // Row to position Edit button right next to the image
                if (photoUrl != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Navigate to EditProfilePage
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfilePage()),
                          );
                        },
                        child: Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue, // Customize color as needed
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getCategoryUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 16),
        CategoryListView(
          callBack: () {},
        ),
      ],
    );
  }

  Widget getPopularCourseUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 18, right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Explore Caste me',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.27,
              color: DesignCourseAppTheme.darkerText,
            ),
          ),
          Flexible(
            child: PopularCourseListView(
              callBack: () {},
            ),
          ),
        ],
      ),
    );
  }
}
