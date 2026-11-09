import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: ViewMyApplication(),
  ));
}

class ViewMyApplication extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<ViewMyApplication> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? '';
    String lid = sh.getString("lid") ?? '';
    try {
      String apiUrl = "$ip/api/actor_view_application"; // Replace with your actual API URL
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'ok') {
          setState(() {
            notifications = List<Map<String, dynamic>>.from(responseData['data']);
          });
        } else {
          print('Failed to fetch Application Data');
        }
      } else {
        print('Failed to fetch Application Data');
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Applications'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 6.0,
      ),
      body: notifications.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> notification = notifications[index];
          return NotificationCard(notification: notification);
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;

  NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    // Determine the status color dynamically
    Color statusColor = notification['application_status'] == 'pending'
        ? Colors.red
        : notification['application_status'] == 'Hired'
        ? Colors.green
        : Colors.black;

    return Card(
      elevation: 8.0, // Increased shadow for more depth
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0), // Rounded corners
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.black26],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['position_vacant'],
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Message: ${notification['description']}',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Date: ${notification['date_time']}',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(
                  notification['application_status'] == 'pending'
                      ? Icons.hourglass_empty
                      : notification['application_status'] == 'Hired'
                      ? Icons.check_circle
                      : Icons.info,
                  color: statusColor,
                ),
                SizedBox(width: 8.0),
                Text(
                  'Status: ${notification['application_status']}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
