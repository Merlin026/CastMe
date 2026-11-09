import 'dart:io';
import 'package:castme/ActorEventCalendarScreen.dart';
import 'package:castme/ActorViewHirings.dart';
import 'package:castme/ActorViewMentorVideos.dart';
import 'package:castme/ActorViewMyApplication.dart';
import 'package:castme/ActorendComplaints.dart';
import 'package:castme/ActorsChatBox.dart';
import 'package:castme/UserViewseminar.dart';
import 'package:castme/ViewPortfolioPage.dart';
import 'package:castme/design_course/home_design_course.dart';
import 'package:castme/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart'; // To pick video files

void main() {
  runApp(UserViewProduct());
}

class UserViewProduct extends StatefulWidget {
  @override
  _UserViewProductState createState() => _UserViewProductState();
}

class _UserViewProductState extends State<UserViewProduct> {
  List<Map<String, dynamic>> hospitalData = [];
  List<Map<String, dynamic>> filteredHospitalData = [];
  List<String> categories = [];
  String selectedCategory = "All"; // Default selection
  String baseUrl = 'http://your_api_base_url'; // Set your server's base URL here
  TextEditingController searchController = TextEditingController();
  TextEditingController messageController = TextEditingController();  // Controller for message text field
  bool isLoading = false;
  XFile? _pickedFile;  // For video file picker

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Cast Me'),
          backgroundColor: Colors.black,
          toolbarHeight: 60,
          actions: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                // Navigate to home screen
              },
            ),
            IconButton(
              icon: Icon(Icons.location_on),
              onPressed: () {
                // Navigate to view place screen
              },
            ),
            IconButton(
              icon: Icon(Icons.assignment),
              onPressed: () {
                // Navigate to view booking screen
              },
            ),
            IconButton(
              icon: Icon(Icons.question_answer),
              onPressed: () {
                // Navigate to enquiry screen
              },
            ),
          ],
        ),
        drawer: Drawer(
          width: 200,
          child: Column(
            children: [
              Container(
                height: 95,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Center(
                    child: Text(
                      'Cast Me',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DesignCourseHomeScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.precision_manufacturing),
                title: Text('Mentorship'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ActorViewMentorVideos()));
                },
              ),
              ListTile(
                leading: Icon(Icons.call),
                title: Text('Casting Calls'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => UserViewProduct()));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings_applications),
                title: Text('Applications'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ViewMyApplication()));
                },
              ),
              ListTile(
                leading: Icon(Icons.note_add),
                title: Text('Seminars'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => UserViewseminar()));
                },
              ),

              ListTile(
                leading: Icon(Icons.surround_sound),
                title: Text('Hirings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ActorViewHirings()));
                },
              ),
              ListTile(
                leading: Icon(Icons.book),
                title: Text('Complaints'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ActorendComplaints()));
                },
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ViewPortfolioPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.event),
                title: Text('Event'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ActorEventCalendarScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Chat'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => CareerGuidanceChatBox()));
                },
              ),



              ListTile(
                leading: Icon(Icons.info),
                title: Text('Sign Out'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => LoginPage()));
                },
              ),
            ],
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Casting Calls',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          filterData();
                        },
                        decoration: InputDecoration(
                          labelText: 'Search By Position',
                          labelStyle: TextStyle(color: Colors.black), // Optional: change label color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8), // Optional: rounded corners
                            borderSide: BorderSide(color: Colors.black, width: 2), // Black border color and width
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black, width: 2), // Black color on focus
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black, width: 2), // Black color when enabled
                          ),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2), // Set border color to black
                      borderRadius: BorderRadius.circular(8), // Optional: Add rounded corners
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                          filterData();
                        });
                      },
                      items: categories.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),

                ],
              ),
              Expanded(
                child: isLoading
                    ? buildLoadingWidget()
                    : filteredHospitalData.isEmpty
                    ? Center(
                  child: Text(
                    'No Casting Call available.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredHospitalData.length,
                  itemBuilder: (context, index) {
                    return buildCard(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(int index) {
    String imageUrl = baseUrl + "/" + filteredHospitalData[index]["file_path"];
    String itemName = filteredHospitalData[index]["type_name"];
    String itemCategory = filteredHospitalData[index]["first_name"];
    String itemtask = filteredHospitalData[index]["task"];
    int vacancyCount = int.parse(filteredHospitalData[index]["no_of_vaccancy"]);

    return InkWell(
      onTap: () {
        _showFullScreenImageWithRate(
            imageUrl,
            itemName,
            itemtask,
            itemCategory,
            vacancyCount,  // Now passing vacancyCount instead of itemRate
            filteredHospitalData[index]["vaccancy_id"].toString()
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full width image with height 350
              Container(
                width: double.infinity,
                height: 350,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Industry: $itemName',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Position: ${filteredHospitalData[index]["position_vacant"]}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Details: ${filteredHospitalData[index]["details"]} ',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 150,
                  child: TextButton(
                    onPressed: () {
                      _showFullScreenImageWithRate(
                          imageUrl,
                          itemName,
                          itemtask,
                          itemCategory,
                          vacancyCount,
                          filteredHospitalData[index]["vaccancy_id"].toString()
                      );
                    },
                    child: Text(
                      'Apply',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImageWithRate(String imageUrl, String itemName, String itemtask, String itemCategory, int vacancyCount, String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SingleChildScrollView(  // Add scrolling functionality
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close Button
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.black),  // Close icon
                        onPressed: () {
                          Navigator.pop(context);  // Close the dialog
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Complete Your Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold, // Make text bold
                        color: Colors.red, // Set text color to red
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '$itemtask',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Director: $itemCategory',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Vacancy: $vacancyCount',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),

                    // TextField for message input
                    TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        labelText: 'Enter Message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Video Upload Button with black color and width
                    ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? pickedFile = await picker.pickVideo(source: ImageSource.gallery);

                        if (pickedFile != null) {
                          setState(() {
                            _pickedFile = pickedFile;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(  // Style the button
                        primary: Colors.black,  // Button color
                        minimumSize: Size(double.infinity, 50),  // Set width
                      ),
                      child: Text('Upload Video'),
                    ),
                    SizedBox(height: 10),

                    // Display the selected video (if any)
                    _pickedFile != null
                        ? Column(
                      children: [
                        Text('Selected Video:'),
                        SizedBox(height: 5),
                        Text(_pickedFile!.name),
                      ],
                    )
                        : Text('No video selected'),

                    SizedBox(height: 10),

                    // Add to Cart Button with black color and width
                    ElevatedButton(
                      onPressed: () async {
                        String message = messageController.text.trim();
                        if (message.isNotEmpty || _pickedFile != null) {
                          // Call handleAddToCart to send message and video
                          await handleAddToCart(itemId, message, _pickedFile);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserViewProduct(),
                            ),
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: "Please enter a message or upload a video.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(  // Style the button
                        primary: Colors.black,  // Button color
                        minimumSize: Size(double.infinity, 50),  // Set width
                      ),
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'BINGE WATCHING WITHOUT BINGE EATING?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        SpinKitFadingCircle(
          color: Colors.cyan,
          size: 50.0,
        ),
      ],
    );
  }

  Future<void> getData() async {
    try {
      setState(() {
        isLoading = true;
      });

      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? '';
      baseUrl = ip;

      final response = await http.post(
        Uri.parse("$baseUrl/api/Actor_view_vecancy"),
      );

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
          setState(() {
            hospitalData = data;
            filteredHospitalData = data;

            // Extract unique categories for dropdown
            categories = data.map<String>((hospital) => hospital["type_name"]).toSet().toList();
            categories.insert(0, "All"); // Add "All" as the default option
            isLoading = false;
          });
        } else {
          Fluttertoast.showToast(
            msg: "Failed: No data",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterData() {
    setState(() {
      filteredHospitalData = hospitalData
          .where((hospital) =>
      (selectedCategory == "All" ||
          hospital["type_name"].toLowerCase() == selectedCategory.toLowerCase()) &&
          (hospital["first_name"]
              .toLowerCase()
              .contains(searchController.text.toLowerCase()) ||
              hospital["position_vacant"]
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()))).toList();
    });
  }

  Future<void> handleAddToCart(String itemId, String message, XFile? videoFile) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip").toString();
      String lid = sh.getString("lid") ?? '';

      String url = ip + "/api/actor_apply_vecancy";

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['vaccancy_id'] = itemId;
      request.fields['lid'] = lid;
      request.fields['message'] = message;

      if (videoFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'video', videoFile.path,
        ));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        String status = jsonDecode(responseBody)['status'];
        if (status == 'success') {
          Fluttertoast.showToast(msg: 'Thank You For Applying For This Post');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserViewProduct(),
            ),
          );
        } else if (status == 'duplicate') {
          Fluttertoast.showToast(msg: 'oops You Are Already Applied');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserViewProduct(),
            ),
          );
        }
      } else {
        Fluttertoast.showToast(msg: 'Failed to add item to cart');
      }
    } catch (a) {
      print(a);
    }
  }
}
