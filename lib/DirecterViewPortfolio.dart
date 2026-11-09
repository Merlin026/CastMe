import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';

class DirecterViewPortfolio extends StatelessWidget {
  final String travelogueId;

  const DirecterViewPortfolio({Key? key, required this.travelogueId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drivers Portfolio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Actor's Portfolio"),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: UserViewDriversWidget(travelogueId: travelogueId),
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
  String baseUrl = '';
  final String travelogueId;

  _UserViewDriversState({required this.travelogueId});

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: driverData.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator if data is empty
          : ListView.builder(
        itemCount: driverData.length,
        itemBuilder: (context, index) {
          return buildCard(index);
        },
      ),
    );
  }

  Widget buildCard(int index) {
    String imageUrl1 = baseUrl + "/" + driverData[index]["image_path"];
    String imageUrl2 = baseUrl + "/" + driverData[index]["image_path2"];
    String imageUrl3 = baseUrl + "/" + driverData[index]["image_path3"];

    return Card(
      elevation: 8.0, // Add shadow effect to the card
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carousel for images
          CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
            ),
            items: [
              Image.network(imageUrl1, fit: BoxFit.cover, width: double.infinity),
              Image.network(imageUrl2, fit: BoxFit.cover, width: double.infinity),
              Image.network(imageUrl3, fit: BoxFit.cover, width: double.infinity),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Title: ${driverData[index]["title"]}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                // Description
                Text(
                  'Description: ${driverData[index]["descriptions"]}',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10),
                // Details Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Age
                        Text(
                          'Age: ${driverData[index]["age"]}',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        SizedBox(height: 5),
                        // Height
                        Text(
                          'Height: ${driverData[index]["height"]}',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        SizedBox(height: 5),
                        // Skin Color
                        Text(
                          'Skin Color: ${driverData[index]["skin_color"]}',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                    // View More Button
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Navigate to another screen with more details
                    //     showMoreDetails(context, index);
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     primary: Colors.blue, // Button color
                    //     onPrimary: Colors.white,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //   ),
                    //   child: Text("View More"),
                    // ),

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getData() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? '';
      baseUrl = ip;

      if (travelogueId.isNotEmpty) {
        final response = await http.post(
          Uri.parse("$baseUrl/api/DirecterViewPortfolio"),
          body: {'member_id': travelogueId},
        );

        if (response.statusCode == 200) {
          String status = jsonDecode(response.body)['status'];
          if (status == 'ok') {
            List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
              jsonDecode(response.body)['data'],
            );

            setState(() {
              driverData = data;
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
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed: TravelogueId is empty",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      print(error);
    }
  }

  // Method to show additional details in a dialog or new screen
  void showMoreDetails(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("More Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${driverData[index]["title"]}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Description: ${driverData[index]["descriptions"]}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Age: ${driverData[index]["age"]}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Height: ${driverData[index]["height"]}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Skin Color: ${driverData[index]["skin_color"]}', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

