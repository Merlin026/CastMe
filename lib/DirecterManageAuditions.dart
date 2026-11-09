import 'dart:convert';
import 'package:castme/UserViewImagesnadvideos.dart';
import 'package:castme/fitness_app/fitness_app_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



void main() {
  runApp(MaterialApp(
    home: DirecterManageAuditions(),
  ));
}

class DirecterManageAuditions extends StatefulWidget {
  @override
  _DirecterManageAuditionsState createState() => _DirecterManageAuditionsState();
}

class _DirecterManageAuditionsState extends State<DirecterManageAuditions> {
  TextEditingController placeController = TextEditingController();
  TextEditingController vecancynoController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isAddVacancyMode = false; // Toggle for showing the add vacancy form

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchIndustryTypes(); // Fetch industry types when the widget initializes
  // }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // When the back button is pressed, navigate to FitnessAppHomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FitnessAppHomeScreen()),
        );
        return false;  // Returning false prevents the default pop behavior
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black, // Set the background color to black
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAddVacancyMode) ...[
                  // Add Vacancy Form Section
                  Text(
                    'Add Vacancy Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: placeController,
                    decoration: InputDecoration(
                      labelText: 'Position Name',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Details',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: vecancynoController,
                    decoration: InputDecoration(
                      labelText: 'Number Of Vacancy',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                    keyboardType: TextInputType.number, // To display the numeric keyboard
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Restrict input to digits only
                    ],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Task About',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),

                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.black87,
                        fixedSize: Size(350, 50), // Set width to 350 and height to 50
                      ),
                      onPressed: () async {
                        if (_validateFields()) {
                          await _sendFeedback();
                        }
                      },
                      child: Text('Add Vacancy'),
                    ),
                  ),
                ] else ...[
                  // View Vacancies Section
                  SizedBox(height: 10),
                  const Divider(),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'View Vacancies',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  FutureBuilder(
                    future: _fetchFeedback(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData && snapshot.requireData['status'] == 'ok') {
                        List<dynamic> feedbackList = snapshot.requireData['data'];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var feedback in feedbackList)
                              FeedbackCard(feedback: feedback),
                          ],
                        );
                      } else {
                        return Text('No Vacancy available');
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop, // Position the FAB at the top right
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 100.0), // Add 50px top padding to FAB
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                isAddVacancyMode = !isAddVacancyMode; // Toggle between add and view mode
              });
            },
            child: Icon(isAddVacancyMode ? Icons.visibility : Icons.add),
            backgroundColor: Colors.black87,
          ),
        ),
      ),
    );
  }

  Future<void> _sendFeedback() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? '';
    String lid = sh.getString("lid") ?? '';

    try {
      String url = "$ip/api/directer_add_auditions";
      final response = await http.post(
        Uri.parse(url),
        body: {
          'lid': lid,
          'position': placeController.text,
          'description': titleController.text,
          'task': descriptionController.text,
          'novecancy': vecancynoController.text,

        },
      );

      if (response.statusCode == 200) {
        _showToast('Vacancy Added successfully');
        setState(() {
          placeController.clear();
          titleController.clear();
          descriptionController.clear();

        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DirecterManageAuditions()),
        );
      } else {
        _showToast('Failed to add Vacancy');
      }
    } catch (error) {
      print(error);
      _showToast('Error sending Vacancy');
    }
  }

  Future<Map<String, dynamic>> _fetchFeedback() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? '';
    String lid = sh.getString("lid") ?? '';

    try {
      String url = "$ip/api/directer_view_auditions";
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

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  bool _validateFields() {
    if (placeController.text.isEmpty ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty ) {
      _showToast('Please fill in all fields');
      return false;
    }
    return true;
  }
}

class FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedback;

  FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  feedback['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteVacancy(feedback['audition_id'].toString());
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => DirecterManageAuditions()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: () {
                        _stopVacancy(feedback['audition_id'].toString());
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => DirecterManageAuditions()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.videocam),
                      onPressed: () {
                        String travelogueId = feedback['audition_id'].toString();
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => UserViewImagesVideos(travelogueId: travelogueId),
                        ));
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text('Title: ${feedback['title']}'),
            SizedBox(height: 8.0),
            Text('Numbers: ${feedback['required_numbers']}'),
            SizedBox(height: 8.0),
            Text('Venue: ${feedback['venue']}'),
            SizedBox(height: 4.0),
            Text('Date: ${feedback['date_time']}'),
            SizedBox(height: 8.0),
            Text('Status: ${feedback['audition_status']}'),
          ],
        ),
      ),
    );
  }
}

Future<void> _deleteVacancy(String vacancyId) async {
  SharedPreferences sh = await SharedPreferences.getInstance();
  String ip = sh.getString("ip") ?? '';
  String lid = sh.getString("lid") ?? '';

  try {
    String url = "$ip/api/deleteauditions";
    final response = await http.post(Uri.parse(url), body: {
      'lid': lid,
      'audition_id': vacancyId,
    });

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Auditions deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to delete auditions",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  } catch (error) {
    print(error);
    Fluttertoast.showToast(
      msg: "Failed to delete auditions",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }
}


Future<void> _stopVacancy(String vacancyId) async {
  SharedPreferences sh = await SharedPreferences.getInstance();
  String ip = sh.getString("ip") ?? '';
  String lid = sh.getString("lid") ?? '';

  try {
    String url = "$ip/api/stopauditions";
    final response = await http.post(Uri.parse(url), body: {
      'lid': lid,
      'audition_id': vacancyId,
    });

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Auditions Stoped successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to Stop auditions",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  } catch (error) {
    print(error);
    Fluttertoast.showToast(
      msg: "Failed to Stop auditions",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }
}
