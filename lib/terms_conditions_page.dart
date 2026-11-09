import 'package:castme/registration.dart';
import 'package:flutter/material.dart';

class TermsConditionsPage extends StatefulWidget {
  @override
  _TermsConditionsPageState createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
  bool _isAccepted = false;

  // Function to handle "Next" button click
  void _onNext() {
    if (_isAccepted) {
      // Navigate to the next page (for example, RegistrationPage)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Registration()),
      );
    } else {
      // Show a message if terms are not accepted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please accept the terms and conditions')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
        backgroundColor: Colors.black, // Black app bar
      ),
      body: SingleChildScrollView( // Allow scroll if content is long
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title of the page with black color
            Text(
              'Terms and Conditions',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Black heading color
              ),
            ),
            SizedBox(height: 20),

            // Terms and Conditions Content
            Text(
              '''1. The registration fee for directors is 3000. This fee covers access to casting calls, workshops, hirings, auditions, job vacancies, and more.
2. Directors will be able to register, and once the payment is completed, the admin will grant access to login.
3. If you are registering as an actor, no registration fee is required.
4. By accepting these terms, you agree to be bound by the conditions mentioned above.
5. Your registration will only be valid after the payment is completed (for directors).''',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            // Terms Acceptance Section
            Row(
              children: [
                // Custom Checkbox
                Checkbox(
                  value: _isAccepted,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAccepted = value ?? false;
                    });
                  },
                  activeColor: Colors.black, // Change checkbox color when active
                ),
                Expanded(
                  child: Text(
                    'I accept the terms and conditions.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // "Next" Button with black background
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black, // Button background color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  elevation: 5,
                ),
                onPressed: _onNext,
                child: Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text color for the button
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
