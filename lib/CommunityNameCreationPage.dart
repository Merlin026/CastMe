import 'dart:convert';
import 'dart:io';
import 'package:castme/CommunityChatBox.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    theme: appTheme,
    home: CommunityNameCreationPage(),
  ));
}

final ThemeData appTheme = ThemeData(
  primaryColor: Colors.black87,
  hintColor: Colors.black,
  textTheme: TextTheme(
    bodyText1: TextStyle(color: Colors.black87),
    bodyText2: TextStyle(color: Colors.black54),
    headline6: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  ),
);

class CommunityNameCreationPage extends StatefulWidget {
  @override
  _GroupNameCreationPageState createState() => _GroupNameCreationPageState();
}

class _GroupNameCreationPageState extends State<CommunityNameCreationPage> {
  TextEditingController groupNameController = TextEditingController();
  File? _selectedImage;
  List<String> selectedMembers = [];
  String baseUrl = '';
  bool isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchBaseUrlAndMembers();
  }

  Future<void> _fetchBaseUrlAndMembers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip") ?? '';
    String lid = prefs.getString("lid") ?? '';
    List<String> members = prefs.getStringList('selectedMembers') ?? [];
    setState(() {
      baseUrl = ip;
      selectedMembers = members;

    });
  }

  Future<void> _selectImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking file: $e");
      _showToast('Error selecting image');
    }
  }

  Future<void> _createGroup() async {
    if (groupNameController.text.isEmpty || _selectedImage == null) {
      _showToast('Please enter a group name and select an image');
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      String apiUrl = "$baseUrl/api/CommunityNameCreationPage";   // Fetch lid from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String lid = prefs.getString("lid") ?? '';


      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['group_name'] = groupNameController.text;
      request.fields['members'] = jsonEncode(selectedMembers);
      request.fields['lid'] = lid; // Pass the lid to the backend


      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _selectedImage!.path,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedData = jsonDecode(responseData);

        if (decodedData['status'] == 'ok') {
          Fluttertoast.showToast(
              msg: "Group created successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CommunityChatBox()),
          );
        } else {
          _showToast('Failed to create group');
        }
      } else {
        _showToast('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error: $e");
      _showToast('Failed to create group');
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Group Name',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 10),
            TextField(
              controller: groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Upload Group Image',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _selectImage,
                  icon: Icon(Icons.file_upload),
                  label: Text('Upload Image'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedImage != null
                        ? 'Selected: ${_selectedImage!.path.split('/').last}'
                        : 'No image selected',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: isUploading ? null : _createGroup,
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: isUploading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text('Create Group', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}