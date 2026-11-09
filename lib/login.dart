import 'dart:convert';
import 'package:castme/ActorViewVecancymages.dart';
import 'package:castme/design_course/home_design_course.dart';
import 'package:castme/fitness_app/fitness_app_home_screen.dart'; // Ensure this import exists for navigation
import 'package:castme/main.dart';
import 'package:castme/terms_conditions_page.dart';
import 'package:castme/user%20home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // When back button is pressed, navigate to IpPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => IpPage()), // Navigate to IpPage
        );
        return false;  // Prevent the default back action
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black,
                  Colors.black87,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 80),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Cast Me",
                        style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Login to your account",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              // Username Text Field Section
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: TextFormField(
                                  controller: usernameController,
                                  decoration: InputDecoration(
                                    hintText: "Enter Username",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter username';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              // Password Text Field Section
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: TextFormField(
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    hintText: "Enter Password",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter password';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              // Login Button Section
                              SizedBox(height: 20),
                              MaterialButton(
                                onPressed: () async {
                                  String uname = usernameController.text.trim();
                                  String password = passwordController.text.trim();

                                  if (uname.isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: "Enter a valid Username",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  } else if (password.isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: "Enter a valid Password",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  } else {
                                    try {
                                      SharedPreferences sh = await SharedPreferences.getInstance();
                                      String ip = sh.getString("ip").toString();
                                      String url = "$ip/api/login";

                                      final response = await http.post(
                                        Uri.parse(url),
                                        body: {
                                          'uname': uname,
                                          'password': password,
                                        },
                                      );

                                      if (response.statusCode == 200) {
                                        String status = jsonDecode(response.body)['status'];

                                        if (status == 'success') {
                                          String type = jsonDecode(response.body)['type'];
                                          String lid = jsonDecode(response.body)['lid'].toString();
                                          String name = jsonDecode(response.body)['name'].toString();
                                          sh.setString("lid", lid);  // Store user ID in SharedPreferences
                                          sh.setString("name", name);  // Store user ID in SharedPreferences

                                          // Navigate based on user type
                                          if (type == 'member') {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => FitnessAppHomeScreen()),
                                            );
                                          } else if (type == 'normal') {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => DesignCourseHomeScreen()),
                                            );
                                          }

                                          Fluttertoast.showToast(
                                            msg: "Login Successful",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: "Invalid Username or Password",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            backgroundColor: Colors.white,
                                            textColor: Colors.red,
                                            fontSize: 16.0,
                                          );
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: "Server error, try again later",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          backgroundColor: Colors.white,
                                          textColor: Colors.red,
                                          fontSize: 16.0,
                                        );
                                      }
                                    } catch (e) {
                                      print(e); // Log any errors that occur during the login process
                                    }
                                  }
                                },
                                height: 50,
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                minWidth: double.infinity,
                              ),
                              SizedBox(height: 20),

                              // GestureDetector for Sign Up navigation
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => TermsConditionsPage()),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_add, color: Colors.black),
                                    SizedBox(width: 8.0),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "New here?",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          "Sign up and get started",
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black54,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),

                              // Social Media Buttons
                              Text("Continue with social media", style: TextStyle(color: Colors.grey)),
                              SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Facebook Button
                                  SocialLoginButton(
                                    color: Colors.blue,
                                    icon: Icons.facebook,
                                    text: "Facebook",
                                    onPressed: () {
                                      // Implement Facebook Login logic
                                    },
                                  ),
                                  SizedBox(width: 20),

                                  // GitHub Button
                                  SocialLoginButton(
                                    color: Colors.black,
                                    icon: Icons.code,
                                    text: "GitHub",
                                    onPressed: () {
                                      // Implement GitHub Login logic
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Google Button
                                  SocialLoginButton(
                                    color: Colors.red,
                                    icon: Icons.mail,
                                    text: "Google",
                                    onPressed: () {
                                      // Implement Google Login logic
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
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

// Social Login Button Widget
class SocialLoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const SocialLoginButton({
    required this.color,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        minimumSize: Size(140, 50),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

