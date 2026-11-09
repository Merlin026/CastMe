import 'dart:convert';
import 'package:castme/UserMakePayment.dart';
import 'package:castme/design_course/home_design_course.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: UserViewseminar(),
  ));
}

class UserViewseminar extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<UserViewseminar> {
  List<Map<String, dynamic>> notifications = [];
  double totalAmount = 0.0;  // To store the total amount

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
      String apiUrl = "$ip/api/UserViewseminar";
      final response = await http.post(Uri.parse(apiUrl), body: {
        'lid': lid,
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'ok') {
          setState(() {
            notifications = List<Map<String, dynamic>>.from(responseData['data']);
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

  // Function to save seminar ID and selected amount
  void saveSelectedReceiverId(String seminar_id, String selectedAmount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('seminar_id', seminar_id);
    prefs.setString('selectedAmount', selectedAmount);

    // Calculate and save the total amount (you can modify this calculation as needed)
    double amount = double.tryParse(selectedAmount) ?? 0.0;
    prefs.setDouble('totalAmount', amount);  // Save total amount in SharedPreferences
  }

  // Function for sending a request to a seminar
  Future<void> _sendRequest(int seminarId) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? '';
    String lid = sh.getString("lid") ?? '';

    try {
      String apiUrl = "$ip/api/user_send_requestforseminar"; // Assuming there's an endpoint for sending requests
      final response = await http.post(Uri.parse(apiUrl), body: {
        'logid': lid.toString(),
        'seminar_id': seminarId.toString(),
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'ok') {
          print('Request sent successfully');
        } else if (responseData['status'] == 'duplicate') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You have already sent seminar request'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          print('Failed to send request');
        }
      } else {
        print('Failed to send request');
      }
    } catch (error) {
      print(error);
    }
  }

  // Function for booking the seminar
  Future<void> _bookNow(int seminarId, String amount) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? '';
    String lid = sh.getString("lid") ?? '';

    try {
      String apiUrl = "$ip/api/user_book_seminar";  // Assuming there's an endpoint for booking
      final response = await http.post(Uri.parse(apiUrl), body: {
        'logid': lid,
        'seminar_id': seminarId.toString(),
        'amount': amount,  // Pass the selected amount to the booking API
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'ok') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking successful'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking failed, please try again later'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('Failed to book seminar');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _showDetailsDialog(Map<String, dynamic> details) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Director Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Director Name: ${details['first_name']} ${details['last_name']}'),
              SizedBox(height: 8.0),
              Text('Phone: ${details['phone']}'),
              SizedBox(height: 8.0),
              Text('Email: ${details['email']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DesignCourseHomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Seminar Details'),
        ),
        body: notifications.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> notification = notifications[index];
            return NotificationCard(
              notification: notification,
              onSendRequestPressed: () {
                _sendRequest(notification['seminar_id']);
              },
              onInfoPressed: () {
                _showDetailsDialog(notification);
              },
              onBookNowPressed: () {
                // Store the seminar id and amount before booking
                saveSelectedReceiverId(notification['seminar_id'].toString(), notification['ticket_amount'].toString());
                _bookNow(notification['seminar_id'], notification['ticket_amount'].toString());
              },
            );
          },
        ),
      ),
    );
  }
}
class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onSendRequestPressed;
  final VoidCallback onInfoPressed;
  final VoidCallback onBookNowPressed;

  NotificationCard({
    required this.notification,
    required this.onSendRequestPressed,
    required this.onInfoPressed,
    required this.onBookNowPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Safely parse 'seats' as an integer
    int availableSeats = int.tryParse(notification['seats'].toString()) ?? 0;

    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text('Details: ${notification['discription']}'),
            SizedBox(height: 4.0),
            Text('Venue: ${notification['venue']}'),
            SizedBox(height: 4.0),
            Text('Date: ${notification['event_date']}'),
            SizedBox(height: 4.0),
            Text('Time: ${notification['date_time']}'),
            SizedBox(height: 4.0),
            Text('Price: ${notification['ticket_amount']}'),
            SizedBox(height: 4.0),
            Text('Seats: $availableSeats'),
            SizedBox(height: 4.0),
            Text('Status: ${notification['status']}'),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: onSendRequestPressed,
                ),
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: onInfoPressed,
                ),
                Spacer(),
                // Only show the "Book Now" button if seats are greater than 0
                if (availableSeats > 0)
                  ElevatedButton(
                    onPressed: () {
                      // Get the ticket amount and seminar ID from the notification data
                      double amount = double.tryParse(notification['ticket_amount'].toString()) ?? 0.0;
                      int seminarId = notification['seminar_id'];  // Get seminar_id

                      // Navigate to the Userpayment screen and pass both the amount and seminar_id
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Userpayment(
                            amount: amount,         // Pass amount
                            seminarId: seminarId,   // Pass seminar ID
                          ),
                        ),
                      );
                    },
                    child: Text('Book Now'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                      textStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                // If no seats available, show a message instead of the button
                if (availableSeats == 0)
                  Text(
                    'Seats are fully booked.',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
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
