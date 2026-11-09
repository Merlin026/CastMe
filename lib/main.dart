import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:castme/login.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    home: IpPage(),
  ),
);

class IpPage extends StatefulWidget {
  @override
  _IpPageState createState() => _IpPageState();
}

class _IpPageState extends State<IpPage> {
  final TextEditingController ipController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Add a global key for the form

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Fetch saved IP from SharedPreferences
  Future<void> _initializeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedIp = prefs.getString('ipa');
    if (savedIp != null) {
      ipController.text = savedIp;
    } else {
      ipController.text = '172.20.10.7:5023'; // Default IP address
    }
  }

  // Method to save IP to SharedPreferences
  Future<void> _saveIp(String ipAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ipa', ipAddress);
    await prefs.setString('ip', 'http://$ipAddress');
  }

  // IP validation logic
  String? _validateIp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an IP address';
    }
    // Add your IP validation logic here if necessary
    return null;
  }

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
    child:Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.black,
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
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Configure Ip Address \n To Continue !",
                      style: TextStyle(color: Colors.white, fontSize: 18),
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
                      SizedBox(height: 160),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            // IP Address Text Field Section
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: TextFormField(
                                controller: ipController,
                                decoration: InputDecoration(
                                  hintText: "Enter IP Address",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateIp,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                // Use double.infinity to fill the container width
                                style: TextStyle(fontSize: 16),
                              ),
                            ),

                            // Space between IP and button
                            SizedBox(height: 20),

                            // Login Button Section
                            MaterialButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  String ipAddress = ipController.text.trim();
                                  await _saveIp(ipAddress);
                                  Fluttertoast.showToast(
                                    msg: "IP Address saved successfully",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(), // Replace `login()` with your login widget's name
                                    ),
                                  );

                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Enter a valid IP address to continue",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
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
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              // Use double.infinity to fill the container width
                              minWidth: double.infinity,
                            ),
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
