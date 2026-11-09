import 'dart:convert';

import 'package:castme/fitness_app/fitness_app_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MaterialApp(
    home: DirectorendComplaints(),
  ));
}

class DirectorendComplaints extends StatefulWidget {
  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<DirectorendComplaints> {
  TextEditingController complaintController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints'),
        backgroundColor: Colors.black, // AppBar background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Complaint',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: complaintController,
                decoration: InputDecoration(
                  labelText: 'Complaint',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  String complaint = complaintController.text.trim();
                  if (complaint.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Enter a valid complaint",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    try {
                      SharedPreferences sh = await SharedPreferences.getInstance();
                      String ip = sh.getString("ip") ?? '';
                      String lid = sh.getString("lid") ?? '';
                      String url = ip + "/api/Director_send_complaint";
                      final response = await http.post(Uri.parse(url),
                          body: {'complaint': complaint, 'lid': lid});

                      if (response.statusCode == 200) {
                        String status = jsonDecode(response.body)['status'];
                        if (status == 'success') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FitnessAppHomeScreen(),
                            ),
                          );
                          Fluttertoast.showToast(
                            msg: "Complaint registered successfully",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      }
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black, // Button color
                  onPrimary: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5, // Adding shadow to button
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("Add Complaint", style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 16),
              Text(
                'View Complaints',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder(
                future: _fetchComplaints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData &&
                      snapshot.requireData['status'] == 'ok') {
                    List<dynamic> complaints = snapshot.requireData['data'];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var complaint in complaints)
                          ComplaintCard(complaint: complaint),
                      ],
                    );
                  } else {
                    return Center(child: Text('No complaints available'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchComplaints() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? '';
    String lid = sh.getString("lid") ?? '';

    try {
      String url = "$ip/api/Director_view_complaint";
      final response = await http.post(Uri.parse(url), body: {
        'lid': lid,
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'failed', 'data': '0.0'};
      }
    } catch (error) {
      print(error);
      return {'status': 'failed', 'data': '0.0'};
    }
  }
}

class ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaint;

  ComplaintCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5, // Adding shadow to cards
      child: ListTile(
        title: Text(
          complaint['complaint_description'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${complaint['reply_description']}'),
            Text('Date: ${complaint['date_time']}'),
          ],
        ),
      ),
    );
  }
}
