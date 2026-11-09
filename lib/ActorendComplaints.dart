import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: ActorendComplaints(),
  ));
}

class ActorendComplaints extends StatefulWidget {
  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ActorendComplaints> {
  TextEditingController complaintController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title for adding complaints
              Text(
                'Add Complaint',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),

              // Text field for complaint
              TextField(
                controller: complaintController,
                decoration: InputDecoration(
                  labelText: 'Complaint',
                  labelStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                maxLines: 5,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // Submit button for adding complaints (Centered)
              Center(
                child: Container(
                  width: 250,  // Set width of the button to 250
                  child: ElevatedButton(
                    onPressed: () async {
                      String complaint = complaintController.text.trim();
                      if (complaint.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Please enter a valid complaint",
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
                          String url = ip + "/api/Actor_send_complaint";
                          final response = await http.post(Uri.parse(url),
                              body: {'complaint': complaint, 'lid': lid});

                          if (response.statusCode == 200) {
                            String status = jsonDecode(response.body)['status'];
                            if (status == 'success') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ActorendComplaints(),
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
                      primary: Colors.black,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text("Add Complaint", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 16),

              // Title for viewing complaints
              Text(
                'View Complaints',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),

              // FutureBuilder to fetch and display complaints
              FutureBuilder(
                future: _fetchComplaints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.requireData['status'] == 'ok') {
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

  // Fetch complaints from the server
  Future<Map<String, dynamic>> _fetchComplaints() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? '';
    String lid = sh.getString("lid") ?? '';

    try {
      String url = "$ip/api/actor_view_complaint";
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

// Complaint Card Widget (with Gradient Background and Larger View)
class ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaint;

  ComplaintCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Colors.black26, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Complaint description
            Text(
              complaint['complaint_description'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 12),
            // Complaint status
            Text(
              'Status: ${complaint['reply_description']}',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 8),
            // Complaint date
            Text(
              'Date: ${complaint['date_time']}',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
