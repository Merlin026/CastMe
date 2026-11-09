import 'package:castme/design_course/home_design_course.dart';
import 'package:castme/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DirectorRegistrationPayment extends StatefulWidget {
  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<DirectorRegistrationPayment> {
  late TextEditingController NameController;
  late TextEditingController NumberController;
  late TextEditingController DateController;
  late TextEditingController cvvController;
  late TextEditingController amountController;

  final _formKey = GlobalKey<FormState>(); // To manage form validation

  @override
  void initState() {
    super.initState();
    NameController = TextEditingController();
    NumberController = TextEditingController();
    DateController = TextEditingController();
    cvvController = TextEditingController();
    amountController = TextEditingController();
    _loadSelectedAmount();
  }

  Future<void> _loadSelectedAmount() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    amountController.text =  '3000';
  }

  _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  bool _isExpiryDateValid(String date) {
    final currentDate = DateTime.now();
    final expiryDate = DateTime.parse("20${date.split('/')[1]}-${date.split('/')[0]}-01"); // Convert to DateTime
    final sixMonthsFromNow = currentDate.add(Duration(days: 182)); // Approximate 6 months

    return expiryDate.isAfter(currentDate) && expiryDate.isBefore(sixMonthsFromNow);
  }

  Future<void> _handlePayment() async {
    if (_formKey.currentState!.validate()) {
      try {
        SharedPreferences sh = await SharedPreferences.getInstance();
        String ip = sh.getString("ip") ?? '';
        String lid = sh.getString("lid") ?? '';
          String url = "$ip/api/DirectorRegistrationPayment";
          final response = await http.post(
            Uri.parse(url),
            body: {

            },
          );
          if (response.statusCode == 200) {
            String status = jsonDecode(response.body)['status'];
            if (status == 'success') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
              Fluttertoast.showToast(
                msg: "Request has been successful",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            } else {
              _showToast("Payment failed. Please try again.");
            }
          } else {
            _showToast("Payment failed. Please try again.");
          }
      } catch (error) {
        _showToast("An error occurred. Please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Payment Page"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey, // Attach the form key
            child: Column(
              children: <Widget>[
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Card Payment",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildTextInputField(
                          controller: NameController,
                          label: "Cardholder's Name",
                          hintText: "John Doe",
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        _buildTextInputField(
                          controller: NumberController,
                          label: "Card Number",
                          hintText: "1234 5678 9012 3456",
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          validator: (value) {
                            if (value == null || value.isEmpty || value.length != 16) {
                              return 'Please enter a valid card number';
                            }
                            return null;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: _buildTextInputField(
                                controller: DateController,
                                label: "Expiry Date",
                                hintText: "MM/YY",
                                keyboardType: TextInputType.datetime,
                                suffixIcon: Icon(Icons.calendar_today),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter expiry date';
                                  }
                                  // if (!_isExpiryDateValid(value)) {
                                  //   return 'Expiry date must be within the next 6 months';
                                  // }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _buildTextInputField(
                                controller: cvvController,
                                label: "CVV",
                                hintText: "123",
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty || value.length != 3) {
                                    return 'Please enter a valid CVV';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildAmountField(),
                        SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: 350,
                            child: ElevatedButton(
                              onPressed: _handlePayment,
                              style: ElevatedButton.styleFrom(
                                primary: Colors.black87,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text("Pay Now", style: TextStyle(fontSize: 18)),
                            ),
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

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    Widget? suffixIcon,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Color.fromARGB(255, 244, 238, 238),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.purple),
            ),
          ),
          style: TextStyle(color: Colors.purple),
          validator: validator,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Amount', style: TextStyle(fontSize: 18, color: Colors.grey)),
        SizedBox(height: 8),
        TextFormField(
          controller: amountController,
          enabled: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: Color.fromARGB(255, 244, 238, 238),
            hintText: 'Amount will be displayed here',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.purple),
            ),
          ),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }
}
