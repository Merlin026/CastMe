import 'dart:convert';
import 'package:castme/GroupChatBox.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'ActorCommunityChatPage.dart';  // Make sure to update ActorCommunityChatPage to accept community_name
import 'ActorsChatBox.dart';
import 'ActorviewDirectors.dart';
import 'GroupChatPeoplesSelection.dart';
import 'design_course/home_design_course.dart';

void main() {
  runApp(MaterialApp(
    home: ActorCommunityBox(),
  ));
}

class ActorCommunityBox extends StatefulWidget {
  @override
  _CareerGuidanceChatBoxState createState() => _CareerGuidanceChatBoxState();
}

class _CareerGuidanceChatBoxState extends State<ActorCommunityBox> {
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
      baseUrl = ip;
    });

    lid = sh.getString("lid") ?? '';
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/ActorCommunityBox"),
        body: {"login_id": lid},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'ok') {
          setState(() {
            notifications = List<Map<String, dynamic>>.from(responseData['data']);
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

  Future<bool> _checkIfMember(String communityId) async {
    try {
      if (lid.isEmpty) {
        Fluttertoast.showToast(msg: "User not logged in.");
        return false;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/api/checkCommunityMember"),
        body: {
          "login_id": lid,
          "community_id": communityId,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['status'] == 'ok';
      } else {
        return false;
      }
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> _joinCommunity(String communityId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/joinCommunity"),
        body: {
          "login_id": lid,
          "community_id": communityId,
          "user_id": userId,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['status'] == 'success';
      } else {
        return false;
      }
    } catch (error) {
      print(error);
      return false;
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
          title: Text('Community Chat'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupChatBox()),
                );
              },
              child: Text(
                'New Group',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CareerGuidanceChatBox()),
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
                  MaterialPageRoute(builder: (context) => ActorCommunityBox()),
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
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          reverse: false,
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> notification = notifications[index];
            return NotificationCard(
              notification: notification,
              baseUrl: baseUrl,
              lid: lid,
              onTap: () async {
                String communityId = notification['mycommunity_id'].toString();
                String userId = notification['user_id'].toString();
                bool isMember = await _checkIfMember(communityId);

                if (isMember) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActorCommunityChatPage(
                        communityId: communityId,  // Pass communityId here
                        communityName: notification['community_name'], // Pass community_name
                      ),
                    ),
                  );
                } else {
                  _showJoinCommunityDialog(communityId, notification['community_name'], userId);
                }
              },
            );
          },
        ),
      ),
    );
  }

  void _showJoinCommunityDialog(String communityId, String communityName, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Join $communityName"),
          content: Text("Do you want to join this community?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                bool joined = await _joinCommunity(communityId, userId);

                if (joined) {
                  Navigator.pop(context);

                  Fluttertoast.showToast(msg: "You have joined $communityName.");

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ActorCommunityChatPage(
                      communityId: communityId,
                      communityName: communityName, // Pass communityName to ActorCommunityChatPage
                    )),
                  );
                } else {
                  Fluttertoast.showToast(msg: "Failed to join community.");
                }
              },
              child: Text("Join"),
            ),
          ],
        );
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final String baseUrl;
  final String lid;
  final Function onTap;

  NotificationCard({
    Key? key,
    required this.notification,
    required this.baseUrl,
    required this.lid,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String CommunID = notification['mycommunity_id'].toString();
    String teamName = notification['community_name'] ?? 'No Name';
    String createDate = notification['create_date'] ?? 'Unknown Date';
    String communityImage = notification['community_image'] ?? 'default.jpg';
    String adminStatus = notification['admin_status'] ?? 'Not Admin';
    String user_id = notification['user_id'].toString();

    return GestureDetector(
      onTap: () => onTap(),
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
                backgroundImage: NetworkImage("$baseUrl/$communityImage"),
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
                      teamName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      'Created: $createDate',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    Text(
                      'Admin Status: $adminStatus',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    Text(
                      'User Id: $user_id',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    Text(
                      'Community ID: $CommunID',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
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
}

void saveSelectedReceiverId(String baseUrl, String CommunID, String teamName, String groupImageUrl) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('CommunID', CommunID);
  prefs.setString('group_name', teamName);

  String fullImageUrl = "$baseUrl/$groupImageUrl";
  prefs.setString('group_image_url', fullImageUrl);
  print('Saved Image URL: $fullImageUrl');
}
