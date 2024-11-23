import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/AdminDashboard.dart';
import 'dashboard.dart';
import 'package:flutter_responsive_login_ui/login_screen.dart';
import 'package:flutter_responsive_login_ui/pallete.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final ipaddress="127.0.0.1";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metro Abet',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Pallete.backgroundColor,
      ),
      //home: LoginScreen(),
      home: AdminDashboard(userId: 3),
      //home: DashboardScreen(userId: 1),
      
      
      //home: LoginScreen(),
    );
  }
}
