import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExpandableItem extends StatefulWidget {
  final int userId;

  const ExpandableItem({super.key, required this.userId});

  @override
  _ExpandableItemState createState() => _ExpandableItemState();
}

class _ExpandableItemState extends State<ExpandableItem> {
  bool _isExpanded = false;
  bool _isLoading = false;
  List<dynamic> _complaints = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchUserComplaints() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse('http://192.168.137.1/fetch_complaints.php?userId=${widget.userId}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _complaints = data['complaints'];
        _isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load user data');
    }
  }

  Widget _buildExpandedContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_complaints.isEmpty) {
      return const Text('No complaints found');
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _complaints.map((complaint) {
          return ExpansionTile(
            title: Text('Complaint ID : ${complaint['comp_id']}'),
            subtitle: Text(complaint['type']),
            children: [
              ListTile(
                title: Text('Metro No: ${complaint['metro_no']}'),
                subtitle: Text('Station No: ${complaint['station_no'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Status: ${complaint['comp_status']}'),
                subtitle: Text('Date: ${complaint['date']} Time: ${complaint['time']}'),
              ),
              ListTile(
                title: Text('Complaint Type: ${complaint['com_type']}'),
              ),
              // Add more details as needed
            ],
          );
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ListTile(
            title: const Text('User Complaints'),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              if (_isExpanded && _complaints.isEmpty) {
                fetchUserComplaints();
              }
            },
            trailing: _isExpanded ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down),
          ),
        ),
        if (_isExpanded) _buildExpandedContent(),
      ],
    );
  }
}
