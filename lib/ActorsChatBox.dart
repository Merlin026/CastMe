import 'dart:convert';
import 'package:castme/ActorCommunityBox.dart';
import 'package:castme/ActorviewDirectors.dart';
import 'package:castme/ChatPage.dart';
import 'package:castme/GroupChatBox.dart';
import 'package:castme/design_course/home_design_course.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: CareerGuidanceChatBox(),
  ));
}

class CareerGuidanceChatBox extends StatefulWidget {
  @override
  _CareerGuidanceChatBoxState createState() => _CareerGuidanceChatBoxState();
}

class _CareerGuidanceChatBoxState extends State<CareerGuidanceChatBox> {
  List<Map<String, dynamic>> notifications = [];
  late String baseUrl;
  late String lid;

  @override
  void initState() {
    super.initState();
    _fetchBaseUrl();
  }

  Future<void> _fetchBaseUrl() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? '';
    setState(() {
      baseUrl = ip; // Update the base URL
    });
    _fetchNotifications(); // Fetch notifications once base URL is set
  }

  Future<void> _fetchNotifications() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      lid = sh.getString("lid") ?? '';
      final response = await http.post(
        Uri.parse("$baseUrl/api/CareerGuidanceChatBox"),
        body: {"login_id": lid},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'ok') {
          setState(() {
            notifications =
            List<Map<String, dynamic>>.from(responseData['data']);
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
          // title: Text('Career Guidance'),
          actions: [
            // TextButton(
            //   onPressed: () {
            //     _fetchNotifications();
            //   },
            //   child: Text(
            //     'Chat Here',
            //     style: TextStyle(color: Colors.white),
            //   ),
            // ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CareerGuidancePage()),
                );
              },
              child: Text(
                'New Chat',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupChatBox()),
                );
              },
              child: Text(
                'Group Chat',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActorCommunityBox()),
                );
              },
              child: Text(
                'Community',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: notifications.isEmpty
            ? Center(
          child: CircularProgressIndicator(),
        )
            : ListView.builder(
          reverse: false,
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> notification = notifications[index];
            return NotificationCard(
                notification: notification, baseUrl: baseUrl);
          },
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
    String imageUrl = "$baseUrl/${notification["member_member_photo"] ?? "default.jpg"}";

    // Function to truncate the message
    String getPreview(String message, int maxLength) {
      if (message.length > maxLength) {
        return message.substring(0, maxLength) + '...';
      }
      return message;
    }

    return GestureDetector(
      onTap: () {
        String loginId = notification["member_member_id"].toString();
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
              // Profile picture
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imageUrl),
                onBackgroundImageError: (error, stackTrace) {
                  print('Error loading image: $error'); // Handle fallback
                },
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Team name and chat time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['team_name'] ?? 'No Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        Text(
                          notification['chat_time'] ?? '',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // Last message (truncated preview)
                    Text(
                      getPreview(notification['message'] ?? 'No message available', 30), // Show only 30 characters
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[700],
                      ),
                    ),
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
