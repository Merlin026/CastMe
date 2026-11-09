import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Map<String, dynamic>? profileData;
  String? baseUrl;
  File? _image;
  final picker = ImagePicker();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController houseNameController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    baseUrl = sh.getString("ip") ?? '';
    String lid = sh.getString("lid") ?? '';

    final response = await http.post(
      Uri.parse("$baseUrl/api/Actor_view_profile"),
      body: {'lid': lid},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'ok') {
        setState(() {
          profileData = data['data'][0];
          firstNameController.text = profileData!['first_name'];
          lastNameController.text = profileData!['last_name'];
          houseNameController.text = profileData!['house_name'];
          placeController.text = profileData!['place'];
          pincodeController.text = profileData!['pincode'];
          genderController.text = profileData!['gender'];
          dobController.text = profileData!['dob'];
          phoneController.text = profileData!['phone'];
          emailController.text = profileData!['email'];
        });
      } else {
        showToast("Failed to load profile data");
      }
    } else {
      showToast("Error loading profile data");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfilePicture() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid") ?? '';
    String url = "$baseUrl/api/Actor_update_profile_picture";

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['lid'] = lid;

    if (_image != null) {
      var image = await http.MultipartFile.fromPath('photo', _image!.path);
      request.files.add(image);
    } else {
      showToast("No image selected");
      return;
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      showToast("Profile picture updated successfully");
      Navigator.pop(context);
    } else {
      showToast("Failed to update profile picture");
    }
  }

  Future<void> _updateProfileDetails() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid") ?? '';
    String url = "$baseUrl/api/Actor_update_profile_details";

    final response = await http.post(
      Uri.parse(url),
      body: {
        'lid': lid,
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'house_name': houseNameController.text,
        'place': placeController.text,
        'pincode': pincodeController.text,
        'gender': genderController.text,
        'dob': dobController.text,
        'phone': phoneController.text,
        'email': emailController.text,
      },
    );

    if (response.statusCode == 200) {
      showToast("Profile details updated successfully");
    } else {
      showToast("Failed to update profile details");
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildProfilePictureSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black26, Colors.white],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _image == null
                ? NetworkImage("$baseUrl/${profileData!['photo']}")
                : FileImage(_image!) as ImageProvider,
          ),
          SizedBox(height: 15),
          TextButton(
            onPressed: _pickImage,
            child: Text(
              'Change Profile',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: _updateProfilePicture,
            child: Text(
              'Save',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailsSection() {
    return Column(
      children: [
        _buildTextField("First Name", firstNameController),
        _buildTextField("Last Name", lastNameController),
        _buildTextField("House Name", houseNameController),
        _buildTextField("Place", placeController),
        _buildTextField("Pincode", pincodeController),
        _buildTextField("Gender", genderController),
        _buildTextField("Date of Birth", dobController),
        _buildTextField("Phone", phoneController),
        _buildTextField("Email", emailController),
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          onPressed: _updateProfileDetails,
          child: Text('Save Profile Details'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            labelStyle: TextStyle(color: Colors.black), // White text color for labels
          ),
          style: TextStyle(color: Colors.black), // White text color for input
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: profileData == null
          ? Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black26, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildProfilePictureSection(),
                SizedBox(height: 20),
                Divider(color: Colors.white),
                _buildProfileDetailsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
