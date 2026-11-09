import 'dart:convert';
import 'package:castme/ActorsChatBox.dart';
import 'package:castme/ActorviewDirectors.dart';
import 'package:castme/ChatPage.dart';
import 'package:castme/CommunityChatPage.dart';
import 'package:castme/CommunityChatPeoplesSelection.dart';
import 'package:castme/fitness_app/fitness_app_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: CommunityChatBox(),
  ));
}

class CommunityChatBox extends StatefulWidget {
  @override
  _CareerGuidanceChatBoxState createState() => _CareerGuidanceChatBoxState();
}

class _CareerGuidanceChatBoxState extends State<CommunityChatBox> {
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
        Uri.parse("$baseUrl/api/CommunityChatBox"),
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
          MaterialPageRoute(builder: (context) => FitnessAppHomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,  // Set the AppBar color to black
          // title: Text('Career Guidance'),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CommunityChatPeoplesSelection()),
                );
              },
              child: Text(
                'New Community',
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

  Future<String> _getGroupImageUrl(String groupId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('community_image$groupId') ??
        "$baseUrl/default.jpg"; // Fallback if not found
  }

  @override
  Widget build(BuildContext context) {
    String groupId = notification['community_id'].toString();
    String teamName = notification['community_name'] ?? 'No Name';

    return GestureDetector(
      onTap: () async {
        String groupImageUrl = await _getGroupImageUrl(groupId);

        saveSelectedReceiverId(groupId, teamName, groupImageUrl);

        // Show the group image URL in a toast message
        Fluttertoast.showToast(
          msg: "Selected Group Image URL: $groupImageUrl",
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
            builder: (context) => CommunityChatPage(),
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
                radius: 30,
                backgroundImage: NetworkImage(
                    "$baseUrl/${notification['community_image'] ?? "default.jpg"}"),
                onBackgroundImageError: (error, stackTrace) {
                  print('Error loading image: $error');
                },
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            teamName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
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
        ),
      ),
    );
  }

  void saveSelectedReceiverId(String groupId, String teamName, String groupImageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('GroupId', groupId);
    prefs.setString('group_name', teamName);
    // Construct the full image URL
    String fullImageUrl = "$baseUrl/$groupImageUrl"; // You can format the URL as needed

    prefs.setString('group_image_url', fullImageUrl); // Save the group image URL
    print('Saved Image URL: $fullImageUrl'); // Optional: for debugging

  }
}
