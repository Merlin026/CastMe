import 'package:castme/fitness_app/fitness_app_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class UserViewImagesVideos extends StatelessWidget {
  final String travelogueId;

  const UserViewImagesVideos({Key? key, required this.travelogueId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // When the back button is pressed, navigate to FitnessAppHomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FitnessAppHomeScreen()),
        );
        return false; // Prevent the default back navigation behavior
      },
      child: MaterialApp(
        // title: 'Smart Travel',
        home: Scaffold(
          appBar: AppBar(
            // title: const Text("Smart Travel"),
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FitnessAppHomeScreen()),
                );
              },
            ),
          ),
          body: UserViewDriversWidget(travelogueId: travelogueId),
        ),
      ),
    );
  }
}

class UserViewDriversWidget extends StatefulWidget {
  final String travelogueId;

  const UserViewDriversWidget({Key? key, required this.travelogueId}) : super(key: key);

  @override
  State<UserViewDriversWidget> createState() => _UserViewDriversState(travelogueId: travelogueId);
}

class _UserViewDriversState extends State<UserViewDriversWidget> {
  List<Map<String, dynamic>> driverData = [];
  String baseUrl = ''; // Set your server's base URL here
  final String travelogueId;

  _UserViewDriversState({required this.travelogueId});

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    for (Map<String, dynamic> data in driverData) {
      VideoPlayerController? videoPlayerController = data['controller'];
      ChewieController? chewieController = data['chewieController'];

      videoPlayerController?.dispose();
      chewieController?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return driverData.isNotEmpty
        ? ListView.builder(
      itemCount: driverData.length,
      itemBuilder: (context, index) {
        return buildCard(index);
      },
    )
        : Center(
      child: Text('No data available'),
    );
  }

  Widget buildCard(int index) {
    if (driverData[index]["file_path"] == null ||
        driverData[index]["file_path"].isEmpty) {
      return Card(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text('Invalid video URL'),
          ],
        ),
      );
    }

    String videoUrl = baseUrl + driverData[index]["file_path_task"];
    print("Video URL: $videoUrl");

    VideoPlayerController videoPlayerController =
    VideoPlayerController.network(videoUrl);

    ChewieController chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: false,
      errorBuilder: (context, errorMessage) {
        print("Chewie error: $errorMessage");
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );

    driverData[index]['controller'] = videoPlayerController;
    driverData[index]['chewieController'] = chewieController;

    return Card(
      child: Column(
        children: [
          Container(
            height: 200,
            child: Chewie(controller: chewieController),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Applicant: ${driverData[index]["applicant_name"]}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Description: ${driverData[index]["description"]}',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Date: ${driverData[index]["date_time"]}',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Add the Hire button here
          ElevatedButton(
            onPressed: () {
              _hireCandidate(driverData[index]["vaccancy_application_id"].toString(), index);
            },
            child: Text('Hire'),
            style: ElevatedButton.styleFrom(
              primary: Colors.green, // Green color for hire button
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> getData() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? '';
      baseUrl = ip + '/';

      final response = await http.post(
        Uri.parse("$baseUrl/api/directer_view_images_videos"),
        body: {'application_id': travelogueId},
      );

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);

          setState(() {
            driverData = data;
          });
        } else {
          showErrorToast("Failed: ${jsonDecode(response.body)['message']}");
        }
      } else {
        showErrorToast(
            "Failed to load data. Server returned ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching data: $error");
      showErrorToast("Error fetching data");
    }
  }

  void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _hireCandidate(String vaccinationApplicationId, int index) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? '';
      baseUrl = ip + '/';

      final response = await http.post(
        Uri.parse("$baseUrl/api/accept_vecncy"),
        body: {'vaccancy_application_id': vaccinationApplicationId},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String status = responseData['status'];

        if (status == 'true') {
          // Successfully hired
          Fluttertoast.showToast(
            msg: "Candidate hired successfully!",
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          // setState(() {
          //   // Remove the hired candidate from the list
          //   driverData.removeAt(index);
          // });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserViewImagesVideos(
                travelogueId: travelogueId, // Pass the travelogueId to the new screen
              ),
            ),
          );
        } else {
          // If the candidate is already hired, show error
          Fluttertoast.showToast(
            msg: "Candidate already hired!",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        // Handle server errors
        Fluttertoast.showToast(
          msg: "Failed to hire candidate. Server returned ${response.statusCode}",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (error) {
      print("Error hiring candidate: $error");
      Fluttertoast.showToast(
        msg: "Error hiring candidate",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
