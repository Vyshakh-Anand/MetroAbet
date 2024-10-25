import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  final int userId;
  const AdminDashboard({Key? key, required this.userId}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to the Admin Dashboard!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement any action you want to perform
              },
              child: Text('Perform Admin Action'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement navigation to other screens
              },
              child: Text('Navigate to Other Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
