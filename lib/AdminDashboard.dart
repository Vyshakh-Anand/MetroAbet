import 'package:flutter/material.dart';
import 'dart:collection';
import 'dart:convert';
import 'datavisualization.dart';
import 'package:flare_flutter/base/actor_ellipse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart'; // For date formatting
import 'package:image_picker/image_picker.dart'; // For image picking
import 'dart:io';
import 'package:getwidget/getwidget.dart';
import 'widgets/comp_expandable.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'widgets/complaint_item_widget.dart';
import 'package:http/http.dart' as http;
import 'globalip.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'globalip.dart';


class AdminDashboard extends StatefulWidget {
  final int userId;
  
  const AdminDashboard({Key? key, required this.userId}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
   List<Map<String, dynamic>> complaints = [];
   String globalip=globalP;
   String _searchQuery = '';
String? _filterType;
  @override
    void initState() {
    super.initState();
    _fetchComplaints(); // Fetch complaints on widget initialization
  }
Future<void> _fetchComplaints() async {
  try {
    final response = await http.get(
      Uri.parse('http://$globalip/fetch_complaints_admin.php'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        complaints = List<Map<String, dynamic>>.from(data['complaints']).map((complaint) {
          return {
            ...complaint,
            'comp_id': int.tryParse(complaint['comp_id'].toString()) ?? 0,
            'u_id': int.tryParse(complaint['u_id'].toString()) ?? 0,
            'metro_no': int.tryParse(complaint['metro_no']?.toString() ?? '0') ?? 0,
            'station_no': int.tryParse(complaint['station_no']?.toString() ?? '0') ?? 0,
          };
        }).toList();
      });
    } else {
      print('Failed to fetch complaints: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    print('Error fetching complaints: $e');
  }
}
Future<String?> _fetchUserEmail(int userId) async {
  try {
    print('Calling fetchUserEmail with u_id: $userId');
    final response = await http.post(
      Uri.parse('http://$globalip/fetch_user_mail_admin.php'),
      body: {'u_id': userId.toString()}, // Send user ID to backend
    );

    print('Response from fetchUserEmail: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Email fetched: ${data['email']}');
      return data['email']; // Ensure your PHP returns the email field
    } else {
      print('Failed to fetch user email: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error fetching user email: $e');
    return null;
  }
}


Future<void> _changeComplaintState(int compId, String newState) async {
  try {
    // Update complaint state
    final response = await http.post(
      Uri.parse('http://$globalip/change_complaint_status_admin.php'),
      body: {
        'comp_id': compId.toString(),
        'new_status': newState,
      },
    );

    if (response.statusCode == 200) {
      print('Complaint state updated successfully!');

      // Refresh the complaints list
      _fetchComplaints();

      // Find the u_id for this complaint
      final complaint = complaints.firstWhere((c) => c['comp_id'] == compId, orElse: () => {});
      if (complaint.isEmpty) {
        print('Complaint not found for compId: $compId');
        return;
      }

      final int userId = complaint['u_id'] ?? 0;
      print('Fetching email for u_id: $userId');

      // Fetch user's email
      final userEmail = await _fetchUserEmail(userId);
      print('Fetched email: $userEmail');

      if (userEmail != null) {
        // Send email notification
        print('Sending email to: $userEmail');
        await sendEmail(userEmail, compId);
      } else {
        print('No email found for u_id: $userId');
      }
    } else {
      print('Failed to update complaint state: ${response.body}');
    }
  } catch (e) {
    print('Error updating complaint state: $e');
  }
}


Future<void> sendEmail(String recipientEmail, int complaintId) async {
  final serviceId = 'service_lc3w83r'; // Replace with your EmailJS service ID
  final templateId = 'template_vggbhtr'; // Replace with your EmailJS template ID
  final userId = 'yxG99MEPjtK-a6RPR'; // Replace with your EmailJS user ID

  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

  final emailData = {
    'service_id': serviceId,
    'template_id': templateId,
    'user_id': userId,
    'template_params': {
      'recipient_email': recipientEmail,
      'Complaint ID': complaintId.toString(), // Match this key to the placeholder in your EmailJS template
    },
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(emailData),
    );

    if (response.statusCode == 200) {
      print('Email sent successfully to $recipientEmail');
    } else {
      print('Failed to send email: ${response.body}');
    }
  } catch (e) {
    print('Error sending email: $e');
  }
}


@override
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Background
        Positioned.fill(
          child: Container(
            color: const Color.fromARGB(255, 255, 94, 94).withOpacity(.7),
          ),
        ),
        // Main content
        Positioned(
          top: 0,
          left: 10,
          right: 10,
          bottom: 10,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 50, bottom: 20),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(child: _buildHeader()),
                ),
                // Navigation button for Data Visualization
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DataVisualizationPage(),
                        ),
                      );
                    },
                    child: const Text('Go to Data Visualization'),
                  ),
                ),
                // Search bar and filter buttons
                _buildSearchBar(),
                // Complaints list
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildComplaintView(),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}



  Widget _buildHeader() {
    return const Row(
      children: [
        Text(
          'Metro Abet',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40,
            color: Color.fromARGB(255, 255, 255, 255),
            letterSpacing: 2.0,
          ),
        ),
        SizedBox(width: 10),
        Icon(
          Icons.train,
          color: Colors.white,
          size: 40,
        ),
      ],
    );
  }
Widget _buildCollapsibleBox(int userId, List<dynamic> complaints) {
  return Row(
    children: [
      Expanded(
        child: Container(

          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            border: Border.all(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
              width: 1.0,
              
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ExpansionTile(
            title: const Text(
              "Your complaints",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            children: complaints.map<Widget>((complaint) {
              // Parse 'comp_id' and 'comp_status' to integers if they are strings
              int compId = complaint['comp_id'] is String ? int.tryParse(complaint['comp_id']) ?? 0 : complaint['comp_id'];
              String compStatus = complaint['type'];

              return MyExpandableList(
                userId: userId,
                compId: compId,
                comptype: compStatus,
              );
            }).toList(),
          ),
        ),
      ),
    ],
  );
}
Widget _buildComplaintView() {
  // Filter complaints based on search query and filter type
  List<Map<String, dynamic>> filteredComplaints = complaints.where((complaint) {
    // Search by Complaint ID
    bool matchesSearch = _searchQuery.isEmpty ||
        complaint['comp_id'].toString().contains(_searchQuery);

    // Filter by tag (metro/station)
    bool matchesFilter = _filterType == null ||
        (_filterType == 'metro' && complaint['metro_no'] != 0) ||
        (_filterType == 'station' && complaint['station_no'] != 0);

    return matchesSearch && matchesFilter;
  }).toList();

  return SingleChildScrollView(
    child: Column(
      children: filteredComplaints.map((complaint) {
        return ComplaintItemWidget(
          compId: complaint['comp_id'] ?? 0,
          type: complaint['type'] ?? 'Unknown',
          status: complaint['comp_status'] ?? 'Unknown',
          date: complaint['date'] ?? 'Unknown',
          time: complaint['time'] ?? 'Unknown',
          details: complaint['comp_details'] ?? 'No details available',
          onChangeState: (compId, newState) {
            _changeComplaintState(compId, newState);
          },
        );
      }).toList(),
    ),
  );
}

Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Column(
      children: [
        // Search bar
        TextField(
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search by Complaint ID...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Filter tags
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFilterButton('Metro', 'metro'),
            _buildFilterButton('Station', 'station'),
          ],
        ),
      ],
    ),
  );
}
Widget _buildFilterButton(String label, String type) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: _filterType == type
          ? const Color.fromARGB(255, 255, 94, 94)
          : Colors.grey[300],
    ),
    onPressed: () {
      setState(() {
        _filterType = (_filterType == type) ? null : type; // Toggle filter
      });
    },
    child: Text(
      label,
      style: TextStyle(
        color: _filterType == type ? Colors.white : Colors.black,
      ),
    ),
  );
}

//6df690bb-380b80a7
//492643fe947510c5664b1899775ff4b3-6df690bb-380b80a7

}

