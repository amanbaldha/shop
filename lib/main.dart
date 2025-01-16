import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_auth/email_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// Define the AuthMode enum for SMTP and OAuth modes
enum AuthMode { SMTP, OAuth }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}

// Splash Screen
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade500,
      body: Center(
        child: Text(
          'Shopping App',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '';
  String _otp = '';

  final emailAuth = EmailAuth(sessionName: "Shopping App");
  String smtpPassword = 'ogrgioqnsjmvuekd';
  // SMTP Configuration for Gmail
  Future<void> configureSMTP() async {
    bool result = await emailAuth.config({
      'server': 'smtp.gmail.com',
      'port': '465',// for SSL
      'authMode': 'SMTP', // SMTP authentication
      'smtpUser': 'amanbaldha01@gmail.com', // Replace with your Gmail address
      'smtpPassword': 'ogrgioqnsjmvuekd', // Use the generated app password
    });

    if (result) {
      print('SMTP server configured successfully');
    } else {
      print('Failed to configure SMTP server');
    }
  }





  // Improved Email validation
  bool _isValidEmail(String email) {
    final trimmedEmail = email.trim();
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(trimmedEmail);
  }

  // Sign in with email and OTP
  Future<User?> _signInWithEmailOTP() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _otp, // Using OTP as password
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in with OTP: $e');
      return null;
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
                  'Login to Continue',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    suffixIcon: TextButton(
                      onPressed: () async {
                        _formKey.currentState?.save();

                        if (_isValidEmail(_email)) {
                          await configureSMTP();  // Configure the SMTP server
                          bool res = await emailAuth.sendOtp(recipientMail: _email);
                          if (res) {
                            print("OTP sent successfully");
                          } else {
                            print("Failed to send OTP");
                          }
                        } else {
                          print("Invalid email format: $_email");
                        }
                      },
                      child: Text("Send OTP", style: TextStyle(color: Colors.black)),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _email = value ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
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
                  obscureText: true,
                  onSaved: (value) => _otp = value ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your OTP';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      final user = await _signInWithEmailOTP();
                      if (user != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ProductPage()),
                        );
                      }
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

// Product Page
class ProductPage extends StatelessWidget {
  final List<Map<String, String>> products = [
    {'name': 'Laptop', 'price': '\$1000'},
    {'name': 'Phone', 'price': '\$500'},
    {'name': 'Headphones', 'price': '\$200'},
    {'name': 'Smart Watch', 'price': '\$150'},
    {'name': 'TV', 'price': '\$750'},
    {'name': 'Mouse', 'price': '\$250'},
    {'name': 'Bluetooth', 'price': '\$550'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8174A0),
      appBar: AppBar(
        backgroundColor: Color(0xFF536493),
        title: Text('Products'),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text(products[index]['name']!),
              subtitle: Text(products[index]['price']!),
            ),
          );
        },
      ),
    );
  }
}
