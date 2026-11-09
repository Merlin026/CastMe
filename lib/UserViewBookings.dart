import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: UserViewbpooking(),
  ));
}

class UserViewbpooking extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<UserViewbpooking> {
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
      String apiUrl = "$ip/api/UserViewbpooking";// Replace with your actual API URL

      final response = await http.post(Uri.parse(apiUrl), body: {
    'lid': lid,

    });
        // You may need to pass any required parameters here
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'ok') {
          setState(() {
            notifications = List<Map<String, dynamic>>.from(responseData['data']);

          });
        } else {
          // Handle other response statuses
          print('Failed to fetch notifications');
        }
      } else {
        // Handle other response statuses
        print('Failed to fetch notifications');
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: notifications.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
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
    return Card(
      elevation: 4.0, // Add elevation for shadow
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Add horizontal margin
      child: Container(
        width: double.infinity, // Set width to match the parent
        padding: EdgeInsets.all(16.0), // Add padding for content spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['title'] ,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0), // Add vertical spacing
            Text('Venue: ${notification['venue']}'),
            SizedBox(height: 4.0), // Add vertical spacing
            Text('Date: ${notification['event_date']}'),
            SizedBox(height: 4.0), // Add vertical spacing
            Text('Time: ${notification['date_time']}'),
            SizedBox(height: 4.0), // Add vertical spacing
            Text('Amount: ${notification['total_amount']}'),
            SizedBox(height: 4.0), // Add vertical spacing
            Text('Status: ${notification['pay_status']}'),
          ],
        ),
      ),
    );
  }
}

