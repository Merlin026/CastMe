import 'package:castme/design_course/home_design_course.dart';
import 'package:castme/fitness_app/fitness_app_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';




class AxtorViewImagesnadvideos extends StatelessWidget {
  final String travelogueId;

  const AxtorViewImagesnadvideos({Key? key, required this.travelogueId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // When the back button is pressed, navigate to FitnessAppHomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DesignCourseHomeScreen()),
        );
        return false; // Prevent the default back navigation behavior
      },
      child: MaterialApp(
        title: 'View Details',
        home: Scaffold(
          appBar: AppBar(
            title: const Text("View Details"),
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
  State<UserViewDriversWidget> createState() => _UserViewDriversState();
}

class _UserViewDriversState extends State<UserViewDriversWidget> {
  List<Map<String, dynamic>> driverData = [];
  String baseUrl = ''; // Set your server's base URL here




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

    String videoUrl = baseUrl + driverData[index]["videos"];
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

          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Title: ${driverData[index]["title"]}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),  // Added fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible( // Use Flexible to allow text to wrap
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
              Flexible( // Use Flexible to allow text to wrap
                child: Text(
                  'Date: ${driverData[index]["date"]}',
                  style: TextStyle(fontSize: 10),
                ),
              ),

            ],
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
      // baseUrl = ip;
      baseUrl = ip + '/';

      final response = await http.post(
        Uri.parse("$baseUrl/api/Actors_view_notification"),
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
}

extension NumericCheck on String {
  bool isNumeric() {
    return double.tryParse(this) != null;
  }
}
