import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:castme/DirectorRegistrationPayment.dart';
import 'package:castme/login.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController houseNameController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedGender = 'Male';
  String _selectedRole = 'Actor';

  File? _selectedFile;
  String? _fileType;
  final ImagePicker _picker = ImagePicker();

  OutlineInputBorder outlineBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.cyan),
    );
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

  Future<void> _selectDOB(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime minDate = DateTime(1900);
    final DateTime maxDate = currentDate.subtract(Duration(days: 365 * 18));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: maxDate,
      firstDate: minDate,
      lastDate: DateTime(2027),
      selectableDayPredicate: (DateTime date) {
        return date.isBefore(currentDate.subtract(Duration(days: 365 * 18)));
      },
    );

    if (picked != null) {
      setState(() {
        dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("Cast Me"),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 5.0,
                shadowColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Registration",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: outlineBorder(),
                          hintText: "First Name",
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                        validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: outlineBorder(),
                          hintText: "Last Name",
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                        validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: houseNameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: outlineBorder(),
                          hintText: "House Name",
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                        validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: placeController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: outlineBorder(),
                          hintText: "Place",
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                        validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: pincodeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: outlineBorder(),
                          hintText: "Pincode",
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter pincode';
                          if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) return 'Enter 6 digits only';
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: outlineBorder(),
                          hintText: "Phone",
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter phone number';
                          if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return 'Enter 10 digits only';
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: outlineBorder(),
                          hintText: "Email",
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                        validator: (value) => value!.isEmpty || !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)
                            ? 'Please enter a valid email' : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: outlineBorder(),
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter password';
                          if (value.length <= 5) return 'Password must be at least 5 characters';
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _selectDOB(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: dobController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: outlineBorder(),
                              hintText: "Date of Birth",
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            validator: (value) => value!.isEmpty ? 'Please select date of birth' : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _selectFile,
                            icon: Icon(Icons.file_upload),
                            label: Text('Select File'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedFile?.path ?? 'No file selected',
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue!;
                          });
                        },
                        items: ['Male', 'Female', 'Other']
                            .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                            .toList(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: outlineBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRole = newValue!;
                          });
                        },
                        items: ['Actor', 'Director', 'Other']
                            .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                            .toList(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: outlineBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _handleSubmit(context),
                        icon: Icon(Icons.send),
                        label: Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? '';
      String url = "$ip/api/${_selectedRole.toLowerCase()}_add_registration";

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields.addAll({
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'house_name': houseNameController.text,
        'place': placeController.text,
        'pincode': pincodeController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'gender': _selectedGender,
        'role': _selectedRole,
        'dob': dobController.text,
      });

      if (_selectedFile != null) {
        request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path));
        request.fields['ftype'] = _fileType ?? '';
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final status = jsonDecode(responseBody)['status'];

      if (response.statusCode == 200 && status == 'success') {
        Fluttertoast.showToast(
          msg: "Thanks For Creating Your Account",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _selectedRole == 'Director'
                ? DirectorRegistrationPayment()
                : LoginPage(),
          ),
        );
      } else if (status == 'duplicate') {
        _showToast("Email or Password already exists");
      } else {
        _showToast("Registration failed");
      }
    } catch (e) {
      print('Error: $e');
      _showToast("Something went wrong. Please try again.");
    }
  }
}