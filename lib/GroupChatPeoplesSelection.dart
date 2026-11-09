import 'dart:convert';
import 'package:castme/GroupNameCreationPage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: GroupChatPeoplesSelection(),
  ));
}

class GroupChatPeoplesSelection extends StatefulWidget {
  @override
  _GroupChatPeoplesSelectionState createState() =>
      _GroupChatPeoplesSelectionState();
}

class _GroupChatPeoplesSelectionState extends State<GroupChatPeoplesSelection> {
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> filteredNotifications = [];
  List<String> selectedMembers = [];
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
    _loadSelectedMembers();
  }

  Future<void> _fetchNotifications() async {
    try {
      String apiUrl = "$baseUrl/api/GroupChatPeoplesSelection";
      final response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'ok') {
          setState(() {
            notifications = List<Map<String, dynamic>>.from(responseData['data']);
            filteredNotifications = notifications;
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

  Future<void> _loadSelectedMembers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
     // selectedMembers = prefs.getStringList('selectedMembers') ?? [];
    });
  }

  Future<void> saveSelectedMembers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('selectedMembers', selectedMembers);
    print('Selected Members: $selectedMembers');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Chat Members Selection'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Name',
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
                Map<String, dynamic> notification =
                filteredNotifications[index];
                return MemberCard(
                  notification: notification,
                  baseUrl: baseUrl,
                  selectedMembers: selectedMembers,
                  onSelectionChange: (String memberId, bool isSelected) {
                    setState(() {
                      if (isSelected) {
                        selectedMembers.add(memberId);
                      } else {
                        selectedMembers.remove(memberId);
                      }
                      saveSelectedMembers();
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupNameCreationPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Next',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final String baseUrl;
  final List<String> selectedMembers;
  final Function(String, bool) onSelectionChange;

  MemberCard({
    required this.notification,
    required this.baseUrl,
    required this.selectedMembers,
    required this.onSelectionChange,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl = baseUrl + "/" + (notification["photo"] ?? "default.jpg");
    String memberId = notification["login_id"].toString();

    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
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
            Checkbox(
              value: selectedMembers.contains(memberId),
              onChanged: (bool? isChecked) {
                onSelectionChange(memberId, isChecked ?? false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

