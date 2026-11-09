import 'dart:async';
import 'package:castme/ActorCommunityBox.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class ActorCommunityChatPage extends StatefulWidget {
  final String communityId;
  final String communityName;

  ActorCommunityChatPage({required this.communityId, required this.communityName});

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<ActorCommunityChatPage> {
  List<Map<String, dynamic>> messages = [];
  late String baseUrl;
  String teamName = '';
  String currentUserId = '';
  String currentCommunID = '';
  String imageUrl = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _fetchTeamDetails();
    _fetchMessages();
    _setupMessagePolling();
  }

  void _setupMessagePolling() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        _fetchMessages();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentUserId() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid") ?? '';
    setState(() {
      currentUserId = lid;
    });
  }

  Future<void> _fetchTeamDetails() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    teamName = sh.getString("group_name") ?? '';
    currentCommunID = sh.getString("CommunID") ?? '';
    imageUrl = sh.getString("group_image_url") ?? '';
    baseUrl = sh.getString("ip") ?? '';

    print('SharedPreferences Details:');
    print('Group Name: $teamName');
    print('Community ID: $currentCommunID');
    print('Group Image URL: $imageUrl');
    print('Base URL: $baseUrl');

    Fluttertoast.showToast(
      msg: "Group Name: $teamName\nCommunity ID: $currentCommunID\nImage URL: $imageUrl",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
    );
  }

  Future<void> _fetchMessages() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid") ?? '';
    String CommunID = widget.communityId;
    baseUrl = sh.getString("ip") ?? '';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/ActorCommunityChatPage'),
        body: {
          'lid': lid,
          'GroupId': CommunID,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'true') {
          setState(() {
            messages = List<Map<String, dynamic>>.from(responseData['data']);
          });
        } else {
          Fluttertoast.showToast(msg: "Failed to fetch messages.");
        }
      } else {
        Fluttertoast.showToast(msg: "Error: Failed to connect to the server.");
      }
    } catch (error) {
      print('Error fetching messages: $error');
      Fluttertoast.showToast(msg: "Error fetching messages.");
    }
  }

  Future<void> _leaveCommunity() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String loginId = sh.getString("lid") ?? '';
    String communityId = widget.communityId;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/actor_leave_community'),
        body: {
          'community_id': communityId,
          'login_id': loginId,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          Fluttertoast.showToast(msg: "You have left the community.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ActorCommunityBox()),
          );
        } else {
          Fluttertoast.showToast(msg: "Failed to leave the community.");
        }
      } else {
        Fluttertoast.showToast(msg: "Error: Failed to connect to the server.");
      }
    } catch (error) {
      print('Error leaving community: $error');
      Fluttertoast.showToast(msg: "Error leaving community.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ActorCommunityBox()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : AssetImage('assets/default_group_image.png')
                  as ImageProvider,
                  onBackgroundImageError: (error, stackTrace) {
                    print('Error loading image: $error');
                  },
                ),
                SizedBox(width: 8.0),
                Text(widget.communityName),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: _leaveCommunity,  // Trigger the leave community action
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _fetchMessages,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> message = messages[index];
                  bool isCurrentUser = message['sender_id'].toString() == currentUserId;
                  return ChatBubble(
                    message: message,
                    isCurrentUser: isCurrentUser,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isCurrentUser;

  ChatBubble({
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.blue[600] : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(isCurrentUser ? 20.0 : 0.0),
                  bottomRight: Radius.circular(isCurrentUser ? 0.0 : 20.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      message['sender_first_name'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 12.0,
                      ),
                    ),
                  Text(
                    message['message'] ?? '',
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message['created_at']),
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white70 : Colors.black54,
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }
}
