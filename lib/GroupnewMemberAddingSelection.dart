import 'dart:convert';
import 'package:castme/design_course/home_design_course.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: GroupnewMemberAddingSelection(),
  ));
}

class GroupnewMemberAddingSelection extends StatefulWidget {
  @override
  _GroupChatPeoplesSelectionState createState() =>
      _GroupChatPeoplesSelectionState();
}

class _GroupChatPeoplesSelectionState extends State<GroupnewMemberAddingSelection> {
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> filteredNotifications = [];
  List<String> selectedMembers = [];
  String baseUrl = '';
  String searchQuery = '';
  String groupId = ''; // Assuming you already have the group ID

  @override
  void initState() {
    super.initState();
    _fetchBaseUrlAndMembers();
  }

  // Fetch the base URL and selected members from SharedPreferences
  Future<void> _fetchBaseUrlAndMembers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip") ?? '';
    String lid = prefs.getString("lid") ?? '';
    String? groupId = prefs.getString('group_id'); // Retrieve group_id from SharedPreferences
    setState(() {
      baseUrl = ip;
      groupId = groupId ?? ''; // Assign group ID to the variable
    });
    _fetchNotifications();
  }

  // Fetch notifications from the API
  Future<void> _fetchNotifications() async {
    try {
      String apiUrl = "$baseUrl/api/GroupnewMemberAddingSelection";
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

  // Filter notifications based on the search query
  void _filterNotifications(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredNotifications = notifications.where((notification) {
        String teamName = notification['team_name']?.toLowerCase() ?? '';
        return teamName.contains(searchQuery);
      }).toList();
    });
  }

  // Handle adding the member to the group
  Future<void> _addMemberToGroup(String memberId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip") ?? '';
    String lid = prefs.getString("lid") ?? '';
    String groupId = prefs.getString("group_id") ?? '';
    String apiUrl = "$baseUrl/api/inserting_intothegroup";  // API URL

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Send the selected member to the backend as a single member (no list)
      request.fields['members'] = memberId;  // Send only the memberId as a string
      request.fields['lid'] = lid;  // Send lid (user ID)
      request.fields['group_id'] = groupId;  // Send group ID

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        // Show success message
        Fluttertoast.showToast(msg: 'Member added to group successfully.', toastLength: Toast.LENGTH_SHORT);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DesignCourseHomeScreen()),
        );
      } else {
        // Show error if the request failed
        Fluttertoast.showToast(msg: 'Member already exists in the group.', toastLength: Toast.LENGTH_SHORT);
      }
    } catch (error) {
      print("Error adding member: $error");
      Fluttertoast.showToast(msg: 'An error occurred. Please try again.', toastLength: Toast.LENGTH_SHORT);
    }
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
                Map<String, dynamic> notification = filteredNotifications[index];
                return MemberCard(
                  notification: notification,
                  baseUrl: baseUrl,
                  selectedMembers: selectedMembers,
                  onSelectionChange: (String memberId, bool isSelected) {
                    setState(() {
                      if (isSelected) {
                        selectedMembers.add(memberId);
                        // Add the member to the group when selected
                        _addMemberToGroup(memberId);
                      } else {
                        selectedMembers.remove(memberId);
                      }
                    });
                  },
                );
              },
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
            IconButton(
              icon: Icon(
                selectedMembers.contains(memberId)
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                color: selectedMembers.contains(memberId) ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                onSelectionChange(memberId, !selectedMembers.contains(memberId));
              },
            ),
          ],
        ),
      ),
    );
  }
}
