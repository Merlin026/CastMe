import 'package:castme/ViewPortfolioPage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PortfolioCreationPage extends StatefulWidget {
  @override
  _PortfolioCreationPageState createState() => _PortfolioCreationPageState();
}

class _PortfolioCreationPageState extends State<PortfolioCreationPage> {
  final _formKey = GlobalKey<FormState>();

  String? title;
  String? descriptions;
  String? age;
  String? location;
  String? height;
  String? skinColor;

  File? image1;
  File? image2;
  File? image3;

  final ImagePicker _picker = ImagePicker();

  // List of skin color options for the dropdown
  final List<String> skinColors = [
    'Fair Skin',
    'Medium Skin',
    'Olive or Light Brown Skin',
    'Brown Skin',
    'Black Skin',
    'White',
    'Gray',
    'Black',
  ];

  Future<void> _pickImage(int imageIndex) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (imageIndex == 1) image1 = File(pickedFile.path);
        if (imageIndex == 2) image2 = File(pickedFile.path);
        if (imageIndex == 3) image3 = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPortfolio() async {
    final SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? '';
    String lid = sh.getString("lid") ?? '';

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String url = "$ip/api/create_portfolio";

      try {
        final request = http.MultipartRequest('POST', Uri.parse(url));
        request.fields['lid'] = lid; // Add lid to the form fields
        request.fields['title'] = title!;
        request.fields['descriptions'] = descriptions!;
        request.fields['age'] = age!;
        request.fields['location'] = location!;
        request.fields['height'] = height!;
        request.fields['skin_color'] = skinColor!; // Use the selected skin color

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Portfolio Created Successfully!')),
          );
          // Navigate to the ViewPortfolioPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ViewPortfolioPage()), // Redirect to ViewPortfolioPage
          );
        } else {
          final responseData = json.decode(await response.stream.bytesToString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Failed to create portfolio')),
          );
        }

      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Portfolio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) => value!.isEmpty ? 'Enter title' : null,
                  onSaved: (value) => title = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Descriptions'),
                  validator: (value) => value!.isEmpty ? 'Enter descriptions' : null,
                  onSaved: (value) => descriptions = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Enter age' : null,
                  onSaved: (value) => age = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) => value!.isEmpty ? 'Enter location' : null,
                  onSaved: (value) => location = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Height'),
                  validator: (value) => value!.isEmpty ? 'Enter height' : null,
                  onSaved: (value) => height = value,
                ),
                // Dropdown for selecting skin color
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Skin Color'),
                  value: skinColor,
                  validator: (value) => value == null ? 'Select a skin color' : null,
                  onChanged: (newValue) {
                    setState(() {
                      skinColor = newValue;
                    });
                  },
                  items: skinColors.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickImage(1),
                        child: Text(image1 == null ? 'Select Image 1' : 'Image 1 Selected'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickImage(2),
                        child: Text(image2 == null ? 'Select Image 2' : 'Image 2 Selected'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickImage(3),
                        child: Text(image3 == null ? 'Select Image 3' : 'Image 3 Selected'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitPortfolio,
                    child: Text('Submit Portfolio'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
