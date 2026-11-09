import 'dart:convert';
import 'dart:math';
import 'package:castme/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;




void main() => runApp(const UserViewDetailsApp());

class UserViewDetailsApp extends StatelessWidget {
  const UserViewDetailsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Travel',
      home: const UserViewDriversWidget(),
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
  List<Map<String, dynamic>> originalDriverData = [];
  String baseUrl = ''; // Set your server's base URL here
  int _currentIndex = 0;
  int selectedDriverId = -1;
  TextEditingController searchController = TextEditingController();

  bool isLoading = true;





  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToHomeView();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "New Place Details",
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _navigateToHomeView();
            },
            color: Colors.white, // Set icon color to white
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.grey, width: 1.0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildRoundButton('Add Travelogue', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserViewDetailsApp()),
                          );

                        }),
                        buildRoundButton('Travelogues ', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserViewDetailsApp()),
                          );


                        }),

                        buildRoundButton('Hotels', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserViewDetailsApp()),
                          );

                        }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildRoundButton('Feedback', () {
                          // Add your button 1 logic here
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserViewDetailsApp()),
                          );
                        }),
                        buildRoundButton('Notifications', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserViewDetailsApp()),
                          );
                        }),

                        buildRoundButton('Sign Out', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        }),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              performSearch(value);
                            },
                            decoration: InputDecoration(
                              labelText: 'Search by Location  Name',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {
                                    driverData = List.from(originalDriverData);
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            String searchQuery = searchController.text;
                            performSearch(searchQuery);
                          },
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: driverData.length,
                itemBuilder: (context, index) {
                  return buildCard(index);
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget buildCard(int index) {
    String imageUrl = baseUrl + "/" + driverData[index]["file_path"];

    return GestureDetector(
      onTap: () {
        showDetailsPopup(driverData[index]);
      },
      child: Card(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${driverData[index]["position_vacant"]}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: IconButton(
                icon: Icon(
                  driverData[index]["isFavorite"] ? Icons.favorite : Icons.favorite_border,
                  color: driverData[index]["isFavorite"] ? Colors.red : null,
                ),
                onPressed: () {
                  toggleFavorite(index, driverData[index]["vaccancy_id"].toString());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDetailsPopup(Map<String, dynamic> driverDetails) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
      return AlertDialog(
          title: Text('More Details'),
    content: Container(
    width: MediaQuery.of(context).size.width * 0.8,
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
    Text('Director: ${driverDetails["first_name"]}'),
    Text('Position: ${driverDetails["position_vacant"]}'),
    Text('Details: ${driverDetails["details"]}'),
    Text('Number Of vecancy: ${driverDetails["no_of_vaccancy"]}'),
    Text('Task: ${driverDetails["task"]}'),
      Text('Status: ${driverDetails["vaccancy_status"]}'),
    ],
    ),
    ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
        },
    );
  }

  void toggleFavorite(int index, String placeId) {
    bool isCurrentlyFavorite = driverData[index]["isFavorite"];
    setState(() {
      driverData[index]["isFavorite"] = !isCurrentlyFavorite;
    });

    if (!isCurrentlyFavorite) {
      addToFavorites(index, placeId);
    } else {
      removeFromFavorites(index, placeId);
    }
  }

  Future<void> addToFavorites(int index, String placeId) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String lid = sh.getString("lid") ?? '';
      String userId = sh.getString("user_id") ?? ''; // Add this line to get the user_id
      String baseUrl = sh.getString("ip") ?? '';

      final response = await http.post(Uri.parse("$baseUrl/api/useradd_to_fever"), body: {
        'lid': lid,
        'user_id': userId, // Add user_id to the request body
        'place_id': placeId,
      });

      print('Add to favorites response status code: ${response.statusCode}');
      print('Add to favorites response body: ${response.body}');

      if (response.statusCode == 200) {
        // Place is not in favorites, update the UI accordingly
        setState(() {
          // Update the isFavorite status
          driverData[index]["isFavorite"] = true;
        });

        // Store the favorite place ID in SharedPreferences
        List<String> favoritePlaces = sh.getStringList("favoritePlaces") ?? [];
        favoritePlaces.add(placeId);
        sh.setStringList("favoritePlaces", favoritePlaces);
      } else {
        // Handle the failure case
        // You might want to revert the state change here
      }
    } catch (error) {
      print('Error in addToFavorites: $error');
      // Handle the error case
      // You might want to revert the state change here
    }
  }

  Future<void> removeFromFavorites(int index, String placeId) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String lid = sh.getString("lid") ?? '';
      String userId = sh.getString("user_id") ?? '';
      String baseUrl = sh.getString("ip") ?? '';

      final response = await http.post(Uri.parse("$baseUrl/api/userremove_from_fever"), body: {
        'lid': lid,
        'user_id': userId,
        'place_id': placeId,
      });

      print('Remove from favorites response status code: ${response.statusCode}');
      print('Remove from favorites response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == 'checked_state') {
          // Place is still in favorites, you might want to handle this case
        } else {
          // Place is removed from favorites, update the UI accordingly
          setState(() {
            driverData[index]["isFavorite"] = false;
          });

          // Remove the favorite place ID from SharedPreferences
          List<String> favoritePlaces = sh.getStringList("favoritePlaces") ?? [];
          favoritePlaces.remove(placeId);
          sh.setStringList("favoritePlaces", favoritePlaces);
        }
      } else {
        // Handle the failure case
      }
    } catch (error) {
      print('Error in removeFromFavorites: $error');
    }
  }

  Future<void> getData() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? '';
      String lid = sh.getString("lid") ?? '';
      baseUrl = ip;

      // Fetch favorite places from interest table
      List<String> favoritePlaceIds = await getFavoritePlaceIds(lid);

      final response = await http.post(Uri.parse("$baseUrl/api/Actor_view_vecancy"), body: {'lid': lid});

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);

          data.forEach((driver) {
            driver["isFavorite"] = favoritePlaceIds.contains(driver["place_id"]); // Set isFavorite based on favoritePlaceIds
          });
          setState(() {
            driverData = data;
            originalDriverData = List.from(data);
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
    } catch (error) {
      print('Error in getData: $error');
    }
  }

  Future<List<String>> getFavoritePlaceIds(String userId) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? '';

      final response = await http.post(Uri.parse("$ip/api/get_favorite_places"), body: {'user_id': userId});

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonDecode(response.body));

        return data.map((favorite) => favorite["place_id"].toString()).toList();
      } else {
        print('Error in getFavoritePlaceIds: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error in getFavoritePlaceIds: $error');
      return [];
    }
  }

  void saveSelectedDriverId(int driverId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedDriverId', driverId);
  }

  void _navigateToHomeView() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserViewDetailsApp()));
  }

  void performSearch(String query) {
    List<Map<String, dynamic>> filteredData = originalDriverData.where((driver) {
      String fullName = '${driver["position_vacant"]} ${driver["first_name"]}'.toLowerCase();
      return fullName.contains(query.toLowerCase()) || driver["last_name"].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      driverData = filteredData;
    });
  }
}
Widget buildRoundButton(String label, VoidCallback onPressed) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 4.0),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.black, // Set the button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white, // Set the text color to white
        ),
      ),
    ),
  );
}

