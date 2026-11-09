import 'dart:convert';
import 'dart:io';
import 'package:castme/UserViewImagesnadvideos.dart';
import 'package:castme/fitness_app/fitness_app_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    theme: appTheme,
    home: DirecterManageVecancy(),
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

class DirecterManageVecancy extends StatefulWidget {
  @override
  _DirecterManageVecancyState createState() => _DirecterManageVecancyState();
}

class _DirecterManageVecancyState extends State<DirecterManageVecancy> {
  TextEditingController placeController = TextEditingController();
  TextEditingController vecancynoController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  Map<String, dynamic>? selectedIndustryType;
  List<Map<String, dynamic>> industryTypes = [];
  bool isAddVacancyMode = false;
  File? _selectedFile;
  String? _fileType;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchIndustryTypes();
  }

  Future<void> _fetchIndustryTypes() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? '';

    try {
      String url = "$ip/api/get_industry_types";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          List<dynamic> types = data['data'];
          setState(() {
            industryTypes = List<Map<String, dynamic>>.from(
                types.map((type) {
                  return {
                    'type_name': type['type_name'],
                    'type_id': type['type_id'],
                  };
                })
            );
          });
        }
      } else {
        _showToast('Failed to fetch industry types');
      }
    } catch (error) {
      print(error);
      _showToast('Error fetching industry types');
    }
  }

  Future<void> _selectFile() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _fileType = 'image';
        });
      }
    } catch (e) {
      print("Error picking file: $e");
      _showToast('Error selecting file');
    }
  }

  Future<void> _sendFeedback() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? '';
    String lid = sh.getString("lid") ?? '';

    try {
      String url = "$ip/api/user_add_vecancy";
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['lid'] = lid;
      request.fields['position'] = placeController.text;
      request.fields['description'] = titleController.text;
      request.fields['task'] = descriptionController.text;
      request.fields['novecancy'] = vecancynoController.text;
      request.fields['industry_id'] = selectedIndustryType?['type_id']?.toString() ?? '';
      request.fields['ftype'] = _fileType ?? '';

      if (_selectedFile != null) {
        request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        _showToast('Vacancy Added successfully');
        setState(() {
          placeController.clear();
          titleController.clear();
          descriptionController.clear();
          selectedIndustryType = null;
          _selectedFile = null;
          _fileType = null;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DirecterManageVecancy()),
        );
      } else {
        _showToast('Failed to add Vacancy');
      }
    } catch (error) {
      print(error);
      _showToast('Error sending Vacancy');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FitnessAppHomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          // title: Text('Manage Vacancies'),
          backgroundColor: Colors.black87,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAddVacancyMode) ...[
                  _buildAddVacancyForm(),
                ] else ...[
                  _buildViewVacanciesSection(),
                ],
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                isAddVacancyMode = !isAddVacancyMode;
              });
            },
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Icon(isAddVacancyMode ? Icons.visibility : Icons.add),
            ),
            backgroundColor: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildAddVacancyForm() {
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Vacancy Details',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 10),
            _buildTextField(placeController, 'Position Name', Icons.work),
            SizedBox(height: 10),
            _buildTextField(titleController, 'Details', Icons.info),
            SizedBox(height: 10),
            _buildTextField(vecancynoController, 'Number Of Vacancy', Icons.format_list_numbered, isNumber: true),
            SizedBox(height: 10),
            _buildTextField(descriptionController, 'Task About', Icons.assignment, maxLines: 3),
            SizedBox(height: 10),
            _buildIndustryDropdown(),
            SizedBox(height: 10),
            _buildFileSelection(),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () async {
                  if (_validateFields()) {
                    await _sendFeedback();
                  }
                },
                child: Text('Add Vacancy', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [ FilteringTextInputFormatter.digitsOnly] : [],
    );
  }

  Widget _buildIndustryDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButton<Map<String, dynamic>>(
          value: selectedIndustryType,
          hint: Text('Select Industry Type', style: TextStyle(color: Colors.black54)),
          isExpanded: true,
          onChanged: (Map<String, dynamic>? newValue) {
            setState(() {
              selectedIndustryType = newValue;
            });
          },
          items: industryTypes.map<DropdownMenuItem<Map<String, dynamic>>>((Map<String, dynamic> type) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: type,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(type['type_name']),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFileSelection() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _selectFile,
          icon: Icon(Icons.file_upload),
          label: Text('Select File'),
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
            'File Path: ${_selectedFile?.path ?? 'No file selected'}',
            style: TextStyle(fontSize: 12, color: Colors.black),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildViewVacanciesSection() {
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'View Vacancies',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(height: 16),
            FutureBuilder(
              future: _fetchFeedback(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent)));
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.requireData['status'] == 'ok') {
                  List<dynamic> feedbackList = snapshot.requireData['data'];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var feedback in feedbackList)
                        FeedbackCard(feedback: feedback),
                    ],
                  );
                } else {
                  return Text('No Vacancy available');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _validateFields() {
    if (placeController.text.isEmpty ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedIndustryType == null ||
        _selectedFile == null) {
      _showToast('Please fill in all fields and select a file');
      return false;
    }
    return true;
  }

  Future<Map<String, dynamic>> _fetchFeedback() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String ip = sh.getString("ip") ?? '';
    String lid = sh.getString("lid") ?? '';

    try {
      String url = "$ip/api/directer_view_vecancy";
      final response = await http.post(Uri.parse(url), body: {
        'lid': lid,
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'failed', 'data': '0.0'};
      }
    } catch (error) {
      print(error);
      return {'status': 'failed', 'data': '0.0'};
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
}

class FeedbackCard extends StatelessWidget {
  final Map <String, dynamic> feedback;

  FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  feedback['position_vacant'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteVacancy(feedback['vaccancy_id'].toString());
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => DirecterManageVecancy()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: () {
                        _stopVacancy(feedback['vaccancy_id'].toString());
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => DirecterManageVecancy()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.videocam),
                      onPressed: () {
                        String travelogueId = feedback['vaccancy_id'].toString();
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => UserViewImagesVideos(travelogueId: travelogueId),
                        ));
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text('Position: ${feedback['position_vacant']}'),
            SizedBox(height: 8.0),
            Text('Description: ${feedback['details']}'),
            SizedBox(height: 8.0),
            Text('Vacancy: ${feedback['no_of_vaccancy']}'),
            SizedBox(height: 4.0),
            Text('Date: ${feedback['date_time']}'),
            SizedBox(height: 8.0),
            Text('Status: ${feedback['vaccancy_status']}'),
          ],
        ),
      ),
    );
  }
}

Future<void> _deleteVacancy(String vacancyId) async {
  SharedPreferences sh = await SharedPreferences.getInstance();
  String ip = sh.getString("ip") ?? '';
  String lid = sh.getString("lid") ?? '';

  try {
    String url = "$ip/api/deletevacancy";
    final response = await http.post(Uri.parse(url), body: {
      'lid': lid,
      'vaccancy_id': vacancyId,
    });

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Vacancy deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to delete vacancy",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  } catch (error) {
    print(error);
    Fluttertoast.showToast(
      msg: "Failed to delete vacancy",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }
}

Future<void> _stopVacancy(String vacancyId) async {
  SharedPreferences sh = await SharedPreferences.getInstance();
  String ip = sh.getString("ip") ?? '';
  String lid = sh.getString("lid") ?? '';

  try {
    String url = "$ip/api/stopvecancy";
    final response = await http.post(Uri.parse(url), body: {
      'lid': lid,
      'vaccancy_id': vacancyId,
    });

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Vacancy Stopped successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to Stop vacancy",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  } catch (error) {
    print(error);
    Fluttertoast.showToast(
      msg: "Failed to stop vacancy",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }
}