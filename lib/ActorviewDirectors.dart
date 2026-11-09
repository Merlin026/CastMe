import 'dart:convert';
import 'package:castme/ChatPage.dart';
import 'package:castme/design_course/home_design_course.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: CareerGuidancePage(),
  ));
}

class CareerGuidancePage extends StatefulWidget {
  @override
  _CareerGuidancePageState createState() => _CareerGuidancePageState();
}

class _CareerGuidancePageState extends State<CareerGuidancePage> {
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> filteredNotifications = [];
  String baseUrl = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchBaseUrl();
  }

  Future<void> _fetchBaseUrl() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? '';
    setState(() {
      baseUrl = ip;
    });
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      String apiUrl = "$baseUrl/api/ActorViewDirectorPage";
      final response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'ok') {
          setState(() {
            notifications = List<Map<String, dynamic>>.from(responseData['data']);
            filteredNotifications = notifications; // Initialize filtered list
          });
        } else {
          print('Failed to fetch notifications');
        }
      } else {
        print('Failed to fetch notifications');
      }
    } catch (error) {
      print(error);
    }
  }

  void _filterNotifications(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredNotifications = notifications.where((notification) {
        String teamName = notification['team_name']?.toLowerCase() ?? '';
        return teamName.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DesignCourseHomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Career Guidance'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search by  Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _filterNotifications,
              ),
            ),
            Expanded(
              child: filteredNotifications.isEmpty
                  ? Center(child: Text('No results found'))
                  : ListView.builder(
                itemCount: filteredNotifications.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> notification = filteredNotifications[index];
                  return NotificationCard(notification: notification, baseUrl: baseUrl);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final String baseUrl;

  NotificationCard({required this.notification, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    String imageUrl = baseUrl + "/" + (notification["photo"] ?? "default.jpg");

    return GestureDetector(
      onTap: () {
        String loginId = notification["login_id"].toString();
        String teamName = notification["team_name"].toString();
        saveSelectedReceiverId(loginId, teamName);

        Fluttertoast.showToast(
          msg: "Selected Receiver ID: $loginId",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(),
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30, // Adjust size as needed
                backgroundImage: NetworkImage(imageUrl),
                onBackgroundImageError: (error, stackTrace) {
                  print('Error loading image: $error');
                },
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['team_name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text('Place: ${notification['place']}'),
                    SizedBox(height: 4.0),
                    Text('Phone: ${notification['phone']}'),
                    SizedBox(height: 4.0),
                    Text('Email: ${notification['email']}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveSelectedReceiverId(String loginId, String teamName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ReciverId', loginId);
    prefs.setString('team_name', teamName);
  }
}
