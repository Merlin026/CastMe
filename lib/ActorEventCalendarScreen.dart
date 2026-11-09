import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,  // Hide debug banner
    theme: ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: TextTheme(
        bodyText1: TextStyle(color: Colors.black, fontSize: 16),
        bodyText2: TextStyle(color: Colors.black54, fontSize: 14),
      ),
    ),
    home: ActorEventCalendarScreen(),
  ));
}

class ActorEventCalendarScreen extends StatefulWidget {
  @override
  _EventCalendarScreenState createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<ActorEventCalendarScreen> {
  late Map<DateTime, List<dynamic>> _events;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  late TextEditingController _venueController;
  late TextEditingController _membersController;
  late String _groupId;
  late String baseUrl;

  // Create a GlobalKey to validate the form fields
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _titleController = TextEditingController();
    _detailsController = TextEditingController();
    _venueController = TextEditingController();
    _membersController = TextEditingController();
    _fetchGroupId();
  }

  Future<void> _fetchGroupId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? groupId = prefs.getString('group_id');
    setState(() {
      _groupId = groupId ?? '';
    });
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lid = prefs.getString('lid');
    String ip = prefs.getString("ip") ?? '';
    baseUrl = ip;

    String apiUrl = '$baseUrl/api/ActorEventCalendarScreen';

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {
        'lid': lid ?? '',
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'true') {
          setState(() {
            _events = {};
            for (var event in data['data']) {
              DateTime eventDate = DateTime.parse(event['date']);
              if (_events[eventDate] == null) {
                _events[eventDate] = [];
              }
              _events[eventDate]?.add(event);
            }
          });
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to fetch events.');
      }
    } catch (error) {
      print("Error fetching events: $error");
    }
  }

  Future<void> _addEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      // If the form is valid, proceed with adding the event
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lid = prefs.getString('lid');
      String ip = prefs.getString("ip") ?? '';
      baseUrl = ip;

      String apiUrl = '$baseUrl/api/add_newevent';

      try {
        final response = await http.post(Uri.parse(apiUrl), body: {
          'lid': lid ?? '',
          'title': _titleController.text,
          'details': _detailsController.text,
          'required_members': _membersController.text,
          'venue': _venueController.text,
          'date': _selectedDay.toIso8601String(),
        });

        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: 'Event added successfully.');
          _fetchEvents();  // Refresh events after adding

          // Clear the fields
          _titleController.clear();
          _detailsController.clear();
          _membersController.clear();
          _venueController.clear();
        } else {
          Fluttertoast.showToast(msg: 'Failed to add event.');
        }
      } catch (error) {
        print("Error adding event: $error");
      }
    } else {
      // If form is invalid, show a message
      Fluttertoast.showToast(msg: 'Please fill in all fields correctly.');
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lid = prefs.getString('lid');
    String ip = prefs.getString("ip") ?? '';
    baseUrl = ip;

    String apiUrl = '$baseUrl/api/delete_event';

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {
        'lid': lid ?? '',
        'event_id': eventId,
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'true') {
          Fluttertoast.showToast(msg: 'Event deleted successfully.');
          _fetchEvents();  // Refresh events after deletion
        } else {
          Fluttertoast.showToast(msg: 'Failed to delete event.');
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to connect to server.');
      }
    } catch (error) {
      print("Error deleting event: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Calendar'),
        backgroundColor: Colors.black,  // Set AppBar background to black
      ),
      body: Stack(  // Wrap the body with Stack to position the Add Event button at the bottom-right
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // TableCalendar with custom theme
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    eventLoader: (day) {
                      return _events[day] ?? [];
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.orange.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronIcon: Icon(Icons.arrow_left, color: Colors.black),
                      rightChevronIcon: Icon(Icons.arrow_right, color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Events List with Card Style
                _events[_selectedDay] == null || _events[_selectedDay]!.isEmpty
                    ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No events for today')),
                )
                    : ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: _events[_selectedDay]!
                      .map((event) => Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      title: Text(
                        event['title'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                        children: [
                          Text(event['venue']),
                          Text(event['first_name']), // Ensure correct spelling of key
                          Text(event['phone']),
                          Text(event['details']),

                        ],
                      ),
                      // Uncomment trailing and onTap if needed
                      // trailing: IconButton(
                      //   icon: Icon(Icons.delete, color: Colors.red), // Red delete icon
                      //   onPressed: () {
                      //     // Convert event_id to a string before passing to _deleteEvent
                      //     _deleteEvent(event['event_id'].toString());
                      //   },
                      // ),
                      // onTap: () {
                      //   // Handle event tap (if needed)
                      // },
                    ),

                  ))
                      .toList(),
                ),
              ],
            ),
          ),

          // FloatingActionButton to add events, positioned at bottom-right corner
          // Positioned(
          //   bottom: 16,
          //   right: 16,
          //   child: FloatingActionButton(
          //     onPressed: () {
          //       _showAddEventDialog(context);
          //     },
          //     backgroundColor: Colors.black,
          //     child: Icon(Icons.add, color: Colors.white),
          //     elevation: 0,
          //   ),
          // ),
        ],
      ),
    );
  }

  // Show dialog with form fields
  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Event'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,  // Assign the form key here
            child: Column(
              children: [
                // Event Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Event Title',
                    labelStyle: TextStyle(color: Colors.black),  // Set the label color to black
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),  // Black border when not focused
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),  // Black border when focused
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),  // Add some space between fields

                // Event Details Field
                TextFormField(
                  controller: _detailsController,
                  decoration: InputDecoration(
                    labelText: 'Event Details',
                    labelStyle: TextStyle(color: Colors.black),  // Set the label color to black
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),  // Black border when not focused
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),  // Black border when focused
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event details';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),  // Add some space between fields

                // Required Members Field
                TextFormField(
                  controller: _membersController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Required Members (Number only)',
                    labelStyle: TextStyle(color: Colors.black),  // Set the label color to black
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),  // Black border when not focused
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),  // Black border when focused
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of required members';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),  // Add some space between fields

                // Venue Field
                TextFormField(
                  controller: _venueController,
                  decoration: InputDecoration(
                    labelText: 'Venue',
                    labelStyle: TextStyle(color: Colors.black),  // Set the label color to black
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),  // Black border when not focused
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),  // Black border when focused
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a venue';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.black,  // Set the background color to black
              primary: Colors.white,  // Set the text color to white
            ),
            child: Text('Cancel'),
          ),

          // Save Button
          ElevatedButton(
            onPressed: () {
              _addEvent();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.black,  // Set the background color to black
            ),
            child: Text(
              'Save Event',
              style: TextStyle(color: Colors.white),  // Set the text color to white for contrast
            ),
          ),
        ],
      ),
    );
  }
}
