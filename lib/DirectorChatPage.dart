import 'dart:async';
import 'package:castme/DirecterViewProfiles.dart';
import 'package:castme/DirectorsChatBox.dart';
import 'package:castme/design_course/home_design_course.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DirectorChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<DirectorChatPage> {
  TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  String baseUrl = '';
  Timer? _timer;
  String teamName = '';

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _startTimer();
    _fetchTeamName();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _fetchMessages();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTeamName() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String teamName = sh.getString("team_name") ?? '';
    setState(() {
      this.teamName = teamName;
    });
  }

  Future<void> _fetchMessages() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid") ?? '';
    String reciverId = sh.getString("ReciverId") ?? '';

    baseUrl = sh.getString("ip") ?? '';
    baseUrl = baseUrl.toString();

    String apiUrl = '$baseUrl/api/chat_director';

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {
        'lid': lid,
        'ReciverId': reciverId,
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'true') {
          setState(() {
            messages = List<Map<String, dynamic>>.from(responseData['data']);
          });
        } else {
          print('Failed to fetch messages');
        }
      } else {
        print('Failed to fetch messages');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _sendMessage(String message) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid") ?? '';
    String reciverId = sh.getString("ReciverId") ?? '';

    baseUrl = sh.getString("ip") ?? '';
    baseUrl = baseUrl.toString();

    String apiUrl = '$baseUrl/api/director_send_message';

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {
        'lid': lid,
        'ReciverId': reciverId,
        'message': message,
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'true') {
          _fetchMessages();
        } else {
          print('Failed to send message');
        }
      } else {
        print('Failed to send message');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _deleteMessage(String chatId) async {
    String apiUrl = '$baseUrl/api/director_delete_message';

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {
        'chat_id': chatId.toString(), // Convert int to String
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'true') {
          setState(() {
            messages.removeWhere((message) => message['chat_id'] == chatId);
          });
        } else {
          print('Failed to delete message');
        }
      } else {
        print('Failed to delete message');
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
          MaterialPageRoute(builder: (context) => DirectorsChatBox()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                AssetImage('assets/chat.jpg'), // Replace with your image
              ),
              SizedBox(width: 8.0),
              Text(teamName),
            ],
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
                shrinkWrap: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> message = messages[index];
                  return ChatBubble(
                    message: message,
                    onDelete: (chatId) => _deleteMessage(chatId.toString()), // Convert int to String here
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

  Widget _buildMessageInput() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: EdgeInsets.all(8.0),
        color: Colors.grey[200],
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                String message = _messageController.text.trim();
                if (message.isNotEmpty) {
                  _sendMessage(message);
                  _messageController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final Function(String chatId) onDelete;

  ChatBubble({required this.message, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    bool isSentByStudent = message['sender_type'] == 'member';

    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context, message['chat_id'].toString()), // Show dialog on long press
      child: Align(
        alignment: isSentByStudent ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isSentByStudent ? Colors.blue : Colors.green,
            borderRadius: isSentByStudent
                ? BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(0.0),
            )
                : BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(0.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          child: Text(
            message['message'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String chatId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Message'),
        content: Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(chatId); // Call the delete function
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
