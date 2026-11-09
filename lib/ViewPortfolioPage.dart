import 'package:castme/PortfolioCreationPage.dart';
import 'package:castme/design_course/home_design_course.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File handling

class ViewPortfolioPage extends StatefulWidget {
  @override
  _ViewPortfolioPageState createState() => _ViewPortfolioPageState();
}

class _ViewPortfolioPageState extends State<ViewPortfolioPage> {
  Map<String, dynamic>? portfolioData;
  bool isLoading = true;
  String? baseUrl;
  late PageController _pageController;
  late Timer _autoSlideTimer;
  int _currentPage = 0;
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController skinColorController = TextEditingController();

  File? image1;
  File? image2;
  File? image3;

  @override
  void initState() {
    super.initState();
    _fetchPortfolio();
    _pageController = PageController();
    _startAutoSlider();
  }

  Future<void> _fetchPortfolio() async {
    final SharedPreferences sh = await SharedPreferences.getInstance();
    baseUrl = sh.getString("ip") ?? '';
    String lid = sh.getString("lid") ?? '';
    String url = "$baseUrl/api/Actor_view_portfolio";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'lid': lid},
      );
      if (response.statusCode == 200) {
        setState(() {
          portfolioData = json.decode(response.body)['data'][0];
          isLoading = false;
          titleController.text = portfolioData!['title'] ?? '';
          descriptionController.text = portfolioData!['descriptions'] ?? '';
          ageController.text = portfolioData!['age'] ?? '';
          heightController.text = portfolioData!['height'] ?? '';
          skinColorController.text = portfolioData!['skin_color'] ?? '';
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch portfolio')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void _startAutoSlider() {
    _autoSlideTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(_currentPage,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  Future<void> _pickImage(int imageNumber) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (imageNumber == 1) {
          image1 = File(pickedFile.path);
        } else if (imageNumber == 2) {
          image2 = File(pickedFile.path);
        } else if (imageNumber == 3) {
          image3 = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _editPortfolio() async {
    final SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid") ?? '';
    String url = "$baseUrl/api/edit_portfolio";
    String portfolioId = portfolioData!['portfolio_id'].toString();

    // Check if all three images are selected before submitting the form
    if (image1 == null || image2 == null || image3 == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please upload all three images')));
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['lid'] = lid;
      request.fields['portfolio_id'] = portfolioId;
      request.fields['title'] = titleController.text;
      request.fields['descriptions'] = descriptionController.text;
      request.fields['age'] = ageController.text;
      request.fields['height'] = heightController.text;
      request.fields['skin_color'] = skinColorController.text;

      if (image1 != null) {
        request.files.add(await http.MultipartFile.fromPath('image1', image1!.path));
      }
      if (image2 != null) {
        request.files.add(await http.MultipartFile.fromPath('image2', image2!.path));
      }
      if (image3 != null) {
        request.files.add(await http.MultipartFile.fromPath('image3', image3!.path));
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Portfolio updated successfully!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DesignCourseHomeScreen()), // Redirect to ViewPortfolioPage
        ); // Close the dialog after submission
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update portfolio')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Portfolio'),
        elevation: 5,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : portfolioData != null
          ? Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          portfolioData!['title'] ?? 'No Title',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        portfolioData!['descriptions'] ?? 'No Description',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSlideshow(),
                  const SizedBox(height: 16),
                  _buildInfoCard('Age', portfolioData!['age'] ?? 'N/A'),
                  _buildInfoCard('Height', portfolioData!['height'] ?? 'N/A'),
                  _buildInfoCard('Skin Color', portfolioData!['skin_color'] ?? 'N/A'),
                ],
              ),
            ),
          ),
          Positioned(
            top: 60,  // Adjust the top margin to be below the AppBar
            right: 16, // Position the button on the right side
            child: ElevatedButton(
              onPressed: () {
                _showEditDialog();
              },
              child: Icon(Icons.edit, size: 30), // Use an icon for edit
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No portfolio found',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to PortfolioCreationPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PortfolioCreationPage(),
                  ),
                );
              },
              child: Text('Create Portfolio'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideshow() {
    List<String> imagePaths = [
      portfolioData!['image_path'],
      portfolioData!['image_path2'],
      portfolioData!['image_path3'],
    ];

    if (imagePaths.isEmpty || imagePaths.every((path) => path == null || path.isEmpty)) {
      return Center(child: Text('No Images Available'));
    }

    imagePaths = imagePaths.where((path) => path != null && path.isNotEmpty).toList();

    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _pageController,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          String imageUrl = "$baseUrl/${imagePaths[index]}";
          return Card(
            elevation: 10,
            margin: EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 18)),
            Text(value, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Portfolio"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: ageController,
                    decoration: InputDecoration(labelText: 'Age'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter age';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: heightController,
                    decoration: InputDecoration(labelText: 'Height'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter height';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: skinColorController,
                    decoration: InputDecoration(labelText: 'Skin Color'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter skin color';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickImage(1),
                    child: Text("Pick Image 1"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickImage(2),
                    child: Text("Pick Image 2"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _pickImage(3),
                    child: Text("Pick Image 3"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _editPortfolio();
                      }
                    },
                    child: Text("Submit"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
