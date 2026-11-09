import 'package:castme/ChatGroupPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> groups = [];

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid") ?? '';

    final response = await http.post(
      Uri.parse("http://<flask_server>/get_groups"),
      body: {"login_id": lid},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['status'] == 'ok') {
        setState(() {
          groups = List<Map<String, dynamic>>.from(responseData['data']);
        });
      }
    } else {
      print('Failed to load groups');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Groups")),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(groups[index]['group_name']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatGroupPage(group: groups[index])),
              );
            },
          );
        },
      ),
    );
  }
}
