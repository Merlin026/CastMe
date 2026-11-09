import 'dart:async';
import 'package:castme/CommunityChatBox.dart';
import 'package:castme/CommunityMembersDetailsPage.dart';
import 'package:castme/GroupDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:castme/design_course/home_design_course.dart';

class CommunityChatPage extends StatefulWidget {
  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<CommunityChatPage> {
  TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  late String baseUrl;
  String teamName = '';
  String currentUserId = '';
  String currentGroupId = '';
  String imageUrl = ''; // Store the group image URL
  String groupImageUrl = ''; // Store the group image URL
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _fetchMessages();
    _fetchTeamDetails();
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
    _messageController.dispose();
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
    setState(() {
      teamName = sh.getString("group_name") ?? '';
      currentGroupId = sh.getString("GroupId") ?? '';
      groupImageUrl = sh.getString("groupImageUrl") ?? ''; // Get the image URL from preferences
      baseUrl = sh.getString("ip") ?? '';
    });
    print('xxxxxxxxxxxxxxxxxxxxxxx Image URL: $teamName'); // Verify the URL
  }


  Future<void> _fetchMessages() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid") ?? '';
    String GroupId = sh.getString("GroupId") ?? '';
    baseUrl = sh.getString("ip") ?? '';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/view_CommunityChatPage'),
        body: {
          'lid': lid,
          'GroupId': GroupId,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'true') {
          setState(() {
            messages = List<Map<String, dynamic>>.from(responseData['data']);
          });
        }
      }
    } catch (error) {
      print('Error fetching messages: $error');
    }
  }

  Future<void> _sendMessage(String message) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid") ?? '';
    String GroupId = sh.getString("GroupId") ?? '';
    baseUrl = sh.getString("ip") ?? '';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/AddcommunityChatPage'),
        body: {
          'lid': lid,
          'GroupId': GroupId,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'true') {
          _messageController.clear();
          _fetchMessages();
        }
      }
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  Future<void> _deleteMessage(String chatId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/community_delete_message'),
        body: {
          'group_id': chatId,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'true') {
          setState(() {
            messages.removeWhere((message) => message['message_id'].toString() == chatId);
          });
        }
      }
    } catch (error) {
      print('Error deleting message: $error');
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              String message = _messageController.text.trim();
              if (message.isNotEmpty) {
                _sendMessage(message);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CommunityChatBox()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityMembersDetailsPage(groupId: currentGroupId),
                ),
              );
            },
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
                Text(teamName),
              ],
            ),
          ),
          actions: [
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
                    onDelete: _deleteMessage,
                    isCurrentUser: isCurrentUser,
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }
}


class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final Function(String) onDelete;
  final bool isCurrentUser;

  ChatBubble({
    required this.message,
    required this.onDelete,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (isCurrentUser) {
          _showDeleteDialog(context, message['message_id'].toString());
        }
      },
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

  void _showDeleteDialog(BuildContext context, String chatId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Message"),
        content: Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(chatId);
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }
}

class GroupDetailsPage extends StatelessWidget {
  final String groupId;

  GroupDetailsPage({required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Details"),
      ),
      body: Center(
        child: Text("Details for group ID: $groupId"),
      ),
    );
  }
}
