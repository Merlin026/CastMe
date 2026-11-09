import 'package:castme/GroupnewMemberAddingSelection.dart';
import 'package:castme/design_course/home_design_course.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityMembersDetailsPage extends StatefulWidget {
  final String groupId;

  CommunityMembersDetailsPage({required this.groupId});

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<CommunityMembersDetailsPage> {
  late String baseUrl;
  List<Map<String, dynamic>> groupMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchGroupDetails();
    _storeGroupDetails(widget.groupId); // Store the group ID on init
  }

  // Fetch group details (members) from the API
  Future<void> _fetchGroupDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      baseUrl = prefs.getString("ip") ?? '';
      final response = await http.post(
        Uri.parse('$baseUrl/api/CommunityMembersDetailsPage'),
        body: {'GroupId': widget.groupId},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'true') {
          setState(() {
            groupMembers = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (error) {
      print('Error fetching group details: $error');
    }
  }

  // Remove a member from the group
  Future<void> _removeMember(String memberId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lid = prefs.getString("lid"); // Assuming user_id is stored in SharedPreferences

      final response = await http.post(
        Uri.parse('$baseUrl/api/delete_community_members'),
        body: {'m_id': memberId, 'lid': lid ?? ''},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'true') {
          // If deletion was successful, remove the member from the list and refresh the page
          setState(() {
            groupMembers.removeWhere((member) => member['m_id'] == memberId);
          });
          _showErrorMessage('Member Removed successfully', Colors.green);

          // Navigate to the DesignCourseHomeScreen on successful deletion
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DesignCourseHomeScreen()),
          );
        } else {
          // If the deletion failed (e.g., user is not admin), show an error message
          _showErrorMessage(data['message'] ?? 'You are not an admin', Colors.red);
        }
      } else {
        _showErrorMessage('Failed to connect to server', Colors.red);
      }
    } catch (error) {
      print('Error removing member: $error');
      _showErrorMessage('An error occurred while trying to remove the member', Colors.red);
    }
  }

  // Function to show a message using Snackbar
  void _showErrorMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  // Function to handle adding a new member
  Future<void> _addMember() async {
    // Navigate to another screen to add a new member or show a dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GroupnewMemberAddingSelection()),
    );

    print("Adding member logic goes here");
  }

  // Store group details in SharedPreferences
  Future<void> _storeGroupDetails(String groupId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store the groupId in SharedPreferences
    await prefs.setString('group_id', groupId);

    print('Group ID saved in SharedPreferences: $groupId');
    _showGroupIdToast(groupId); // Show a toast/snackbar with the group ID
  }

  // Show a Toast or SnackBar with the Group ID
  void _showGroupIdToast(String groupId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Group ID saved: $groupId'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Members'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: _addMember, // Open add member functionality
          ),
        ],
      ),
      body: groupMembers.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator if no members are found
          : ListView.builder(
        itemCount: groupMembers.length,
        itemBuilder: (context, index) {
          final member = groupMembers[index];
          String memberImageUrl = "$baseUrl/${member['photo'] ?? 'default.jpg'}";

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(memberImageUrl),
              onBackgroundImageError: (error, stackTrace) {
                print('Error loading image: $error');
              },
            ),
            title: Text(member['first_name'] ?? 'Unknown'),
            subtitle: Text(
              '${member['role'] ?? 'Member'}\nID: ${member['m_id'] ?? 'Not available'}\nID: ${member['group_id'] ?? 'Not available'}'
                  '\nStatus: ${member['admin_status'] ?? 'Not Admin'}',
              style: TextStyle(fontSize: 14),
            ),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeMember(member['m_id'].toString()), // Convert m_id to String
            ),
          );
        },
      ),
    );
  }
}
