import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();

  Future<void> createGroup(String groupName) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid") ?? '';

    final response = await http.post(
      Uri.parse("http://<flask_server>/create_group"),
      body: {"group_name": groupName, "login_id": lid},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['status'] == 'ok') {
        Navigator.pop(context);
      }
    } else {
      print('Failed to create group');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Group")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(labelText: "Group Name"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                createGroup(_groupNameController.text);
              },
              child: Text("Create Group"),
            ),
          ],
        ),
      ),
    );
  }
}
