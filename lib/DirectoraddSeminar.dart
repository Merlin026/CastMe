import 'dart:convert';
import 'package:castme/fitness_app/fitness_app_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MaterialApp(
    home: DirectoraddSeminar(),
  ));
}

class DirectoraddSeminar extends StatefulWidget {
  @override
  _DirectoraddSeminarState createState() => _DirectoraddSeminarState();
}

class _DirectoraddSeminarState extends State<DirectoraddSeminar> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController venueController = TextEditingController();
  TextEditingController seatsController = TextEditingController(); // Controller for seats
  TextEditingController ticketAmountController = TextEditingController(); // New controller for ticket amount
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seminar'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Seminar Details',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.black),
                    onPressed: () => _showAddSeminarModal(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
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
                          ComplaintCard(
                            complaint: complaint,
                            onDelete: () => _deleteSeminar(complaint['seminar_id']),
                          ),
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
      String url = "$ip/api/Director_view_seminar";
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

  Future<void> _deleteSeminar(dynamic seminarId) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? '';
      String url = "$ip/api/Director_delete_seminar";

      String seminarIdStr = seminarId.toString();

      final response = await http.post(Uri.parse(url), body: {
        'seminar_id': seminarIdStr,
      });

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'success') {
          Fluttertoast.showToast(
            msg: "Seminar deleted successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {});
        } else {
          Fluttertoast.showToast(
            msg: "Failed to delete seminar",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _showAddSeminarModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Seminar Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 16),
                _buildTextField('Title', titleController),
                SizedBox(height: 16),
                _buildTextField('Description', descriptionController, maxLines: 3),
                SizedBox(height: 16),
                _buildTextField('Venue', venueController),
                SizedBox(height: 16),
                _buildTextField('Number of Seats', seatsController, keyboardType: TextInputType.number),
                SizedBox(height: 16),
                _buildTextField('Ticket Amount', ticketAmountController, keyboardType: TextInputType.number), // New field
                SizedBox(height: 16),
                _buildDateTimeSelector(context),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _addSeminar,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text("Add Seminar", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
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
      maxLines: maxLines,
    );
  }

  Widget _buildDateTimeSelector(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("Event Date: "),
            Text("${selectedDate.toLocal()}".split(' ')[0]),
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: _selectDate,
            ),
          ],
        ),
        Row(
          children: [
            Text("Event Time: "),
            Text("${selectedTime.format(context)}"),
            IconButton(
              icon: Icon(Icons.access_time),
              onPressed: _selectTime,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _addSeminar() async {
    String title = titleController.text.trim();
    String description = descriptionController.text.trim();
    String venue = venueController.text.trim();
    String seats = seatsController.text.trim();
    String ticketAmount = ticketAmountController.text.trim(); // Get the ticket amount

    if (title.isEmpty || description.isEmpty || venue.isEmpty || seats.isEmpty || ticketAmount.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill all the fields",
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
        String url = ip + "/api/Director_add_seminar";
        final response = await http.post(Uri.parse(url), body: {
          'title': title,
          'description': description,
          'venue': venue,
          'event_date': selectedDate.toIso8601String(),
          'event_time': selectedTime.format(context),
          'seats': seats, // Send seats to the API
          'ticket_amount': ticketAmount, // Send ticket amount to the API
          'lid': lid,
        });

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
              msg: "Seminar registered successfully",
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
  }

  Future<void> _selectDate() async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ) ?? selectedDate;

    setState(() {
      selectedDate = picked;
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    ) ?? selectedTime;

    setState(() {
      selectedTime = picked;
    });
  }
}

class ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaint;
  final VoidCallback onDelete;

  ComplaintCard({required this.complaint, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: ListTile(
        title: Text(
          complaint['title'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Details: ${complaint['discription']}'),
            Text('Date: ${complaint['event_date']}'),
            Text('Time: ${complaint['date_time']}'),
            Text('Venue: ${complaint['venue']}'),
            Text('Seats: ${complaint['seats']}'), // Display number of seats
            Text('Ticket Amount: ${complaint['ticket_amount']}'), // Display ticket amount
            Text('Status: ${complaint['status']}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
