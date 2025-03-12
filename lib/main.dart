import 'package:flutter/material.dart';
import 'post_screen.dart'; // Import the PostScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'API Fetching App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PostScreen(), // Set PostScreen as the home
    );
  }
}
