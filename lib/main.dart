import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shop/splash_screen.dart';
import 'package:email_otp/email_otp.dart';

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





