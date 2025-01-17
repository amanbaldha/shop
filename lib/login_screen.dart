import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop/product_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _mobileNumber = '';
  String _otp = '';
  String? _verificationId;

  // Send OTP to the entered mobile number
  Future<void> _sendOTP() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$_mobileNumber',
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatically signs in the user on successful verification
          await _auth.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProductPage()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
          print('OTP sent to +91$_mobileNumber');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP sent to +91$_mobileNumber')),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      print('Error sending OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending OTP: $e')),
      );
    }
  }

  // Verify the entered OTP
  Future<void> _verifyOTP() async {
    if (_verificationId != null && _otp.isNotEmpty) {
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: _otp,
        );
        final userCredential = await _auth.signInWithCredential(credential);

        if (userCredential.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProductPage()),
          );
        }
      } catch (e) {
        print('Error verifying OTP: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error verifying OTP: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid OTP.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent.shade100,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login with Mobile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    suffixIcon: TextButton(
                      onPressed: () {
                        _formKey.currentState?.save();
                        if (_mobileNumber.isNotEmpty && _mobileNumber.length == 10) {
                          _sendOTP();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Enter a valid mobile number.')),
                          );
                        }
                      },
                      child: Text('Send OTP', style: TextStyle(color: Colors.black)),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => _mobileNumber = value ?? '',
                  validator: (value) {
                    final mobileRegex = RegExp(r'^[6-9]\d{9}$');
                    if (value == null || value.isEmpty || !mobileRegex.hasMatch(value)) {
                      return 'Please enter a valid mobile number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _otp = value ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 6) {
                      return 'Please enter a valid OTP';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      _verifyOTP();
                    }
                  },
                  child: Text('Verify OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
