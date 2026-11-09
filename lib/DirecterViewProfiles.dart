import 'dart:async';
import 'dart:convert';
import 'package:castme/ChatPage.dart';
import 'package:castme/DirecterViewPortfolio.dart';
import 'package:castme/DirectorChatPage.dart';
import 'package:castme/fitness_app/fitness_app_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const DirecterViewProfiles());

class DirecterViewProfiles extends StatelessWidget {
  const DirecterViewProfiles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Booking Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Add a more modern font
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Actors Profiles"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: const UserViewDriversWidget(),
      ),
    );
  }
}

class UserViewDriversWidget extends StatefulWidget {
  const UserViewDriversWidget({Key? key}) : super(key: key);

  @override
  State<UserViewDriversWidget> createState() => _UserViewDriversState();
}

class _UserViewDriversState extends State<UserViewDriversWidget> {
  List<Map<String, dynamic>> driverData = [];
  String baseUrl = ''; // Set your server's base URL here
  // Timer? _timer; // Declare a Timer variable for periodic refresh


  // Filters
  String? selectedAgeRange;
  String? selectedHeightRange;
  String? selectedSkinColor;

  // Available options for filters
  List<String> ageRanges = ['10-20', '21-30', '31-40', '41-50', '51-60', '61-70', '71-80', '81-95'];
  List<String> skinColors = [
    'Fair Skin', 'Medium Skin', 'Olive or Light Brown Skin', 'Brown Skin',
    'Black Skin', 'White', 'Gray', 'Black'
  ];
  List<String> heightRanges = ['100-120', '121-140', '141-160', '161-180', '181-190', '190+'];

  @override
  void initState() {
    super.initState();
    getData(); // Fetch data initially

    // Start the periodic refresh every 3 seconds
    // _timer = Timer.periodic(Duration(seconds: 3), (Timer t) => getData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Age Range Dropdown
                _buildDropdown(
                  label: 'Age Range',
                  value: selectedAgeRange,
                  items: ageRanges,
                  onChanged: (value) {
                    setState(() {
                      selectedAgeRange = value;
                      selectedHeightRange = null;
                      selectedSkinColor = null;
                    });
                    getData();
                  },
                ),
                const SizedBox(width: 10),
                // Height Range Dropdown
                _buildDropdown(
                  label: 'Height Range (cm)',
                  value: selectedHeightRange,
                  items: heightRanges,
                  onChanged: (value) {
                    setState(() {
                      selectedHeightRange = value;
                      selectedAgeRange = null;
                      selectedSkinColor = null;
                    });
                    getData();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column( // Use Column to stack the rows vertically
              children: [
                Row(
                  children: [
                    // Skin Color Dropdown
                    _buildDropdown(
                      label: 'Skin Color',
                      value: selectedSkinColor,
                      items: skinColors,
                      onChanged: (value) {
                        setState(() {
                          selectedSkinColor = value;
                          selectedAgeRange = null;
                          selectedHeightRange = null;
                        });
                        getData();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Space between the rows
                Row(
                  children: [
                    // Clear Button with smaller size
                    ElevatedButton(
                      onPressed: clearAllFilters,
                      child: const Text('Clear Filters'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Smaller padding
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),


          // Display the filtered list
          Expanded(
            child: ListView.builder(
              itemCount: driverData.length,
              itemBuilder: (context, index) {
                return buildCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        items: items.map((range) {
          return DropdownMenuItem<String>(
            value: range,
            child: Text(range),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );

  }

  void clearAllFilters() {
    setState(() {
      selectedAgeRange = null;
      selectedHeightRange = null;
      selectedSkinColor = null;
      driverData = [];
    });
    getData();
  }

  Widget buildCard(int index) {
    String imageUrl = baseUrl + "/" + driverData[index]["photo"];

    return Card(
      elevation: 8.0,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Driver Image
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(width: 20),

            // Driver Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${driverData[index]["first_name"]} ${driverData[index]["last_name"]}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Place: ${driverData[index]["place"]}', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Gender: ${driverData[index]["gender"]}', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Phone: ${driverData[index]["phone"]}', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      // Ensure `member_id` is converted to a string and stop the vacancy
                      _stopVacancy(driverData[index]["member_id"].toString());

                      // Navigate to DirecterViewProfiles screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DirecterViewProfiles()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,  // Background color
                      onPrimary: Colors.black,      // Text and icon color
                      elevation: 0,
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,  // Ensures the row takes minimum space
                      children: [
                        Icon(Icons.more, color: Colors.black),
                        SizedBox(width: 8),  // Adds spacing between icon and text
                        Text(
                          'Hire Here',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: () {
                      String loginId = driverData[index]["login_id"].toString();
                      String teamName = driverData[index]["team_name"];

                      // Save the selected receiver's loginId and teamName to shared preferences
                      saveSelectedReceiverId(loginId, teamName);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DirectorChatPage(),
                        ),
                      );
                    },
                    icon: Icon(Icons.chat, color: Colors.black),
                    label: Text('Chat', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onPrimary: Colors.black,
                      elevation: 0,
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),


                  ElevatedButton.icon(
                    onPressed: () {
                      saveSelectedDriverId(driverData[index]["member_id"].toString());
                      String travelogueId = driverData[index]["member_id"].toString();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DirecterViewPortfolio(travelogueId: travelogueId),
                        ),
                      );
                    },
                    icon: Icon(Icons.more, color: Colors.black),
                    label: Text('Read More', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onPrimary: Colors.black,
                      elevation: 0,
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getData() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? '';
      String lid = sh.getString("lid") ?? '';
      baseUrl = ip;

      final response = await http.post(
        Uri.parse("$baseUrl/api/DirecterViewProfiles"),
        body: {
          'lid': lid,
          'age': selectedAgeRange ?? '',
          'height': selectedHeightRange ?? '',
          'skin_color': selectedSkinColor ?? ''
        },
      );

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
          setState(() {
            driverData = data;
          });
        } else {
          Fluttertoast.showToast(
            msg: "Failed: No data",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } catch (error) {
      print("Error in fetching data: $error");
    }
  }
}

void saveSelectedDriverId(String member_id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('member_id', member_id);
}


Future<void> _stopVacancy(String memberId) async {
  SharedPreferences sh = await SharedPreferences.getInstance();
  String ip = sh.getString("ip") ?? '';
  String lid = sh.getString("lid") ?? '';

  // Check if IP or lid is empty and show a message
  if (ip.isEmpty || lid.isEmpty) {
    Fluttertoast.showToast(
      msg: "IP or LID is missing. Please check your settings.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    return;
  }

  try {
    // Construct the URL with the provided IP
    String url = "$ip/api/hireactor"; // Ensure correct endpoint name

    // Send the POST request with the body parameters
    final response = await http.post(Uri.parse(url), body: {
      'lid': lid,
      'member_id': memberId, // Sending memberId as intended
    });

    // Check the response status code and handle accordingly
    if (response.statusCode == 200) {
      // Successfully hired actor
      Fluttertoast.showToast(
        msg: "Actor Hired successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } else {
      // Failed to hire actor, check the response body for details
      String errorMessage = "Failed to hire actor. Please try again.";
      try {
        // Attempt to parse the response body for more error details
        final responseBody = response.body;
        Fluttertoast.showToast(
          msg: "Failed to stop vacancy: $responseBody",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } catch (e) {
        // If response body is not a JSON or cannot be parsed
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  } catch (error) {
    // Catch any unexpected errors
    print("Error stopping vacancy: $error");
    Fluttertoast.showToast(
      msg: "Failed to stop vacancy due to an error.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
void saveSelectedReceiverId(String loginId, String teamName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('ReceiverId', loginId);
  prefs.setString('team_name', teamName);
}

