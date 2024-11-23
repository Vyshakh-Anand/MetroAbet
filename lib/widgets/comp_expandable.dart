import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/globalip.dart';
import 'package:http/http.dart' as http;

class MyExpandableList extends StatelessWidget {
  final int userId;
  final int compId;
  final String comptype;

  const MyExpandableList({super.key, required this.userId, required this.compId, required this.comptype});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title:
      Container(
        decoration: BoxDecoration(
                color: const Color.fromARGB(51, 168, 168, 168),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                              color: const Color.fromARGB(124, 255, 47, 47),
                              width: 2,
                            ),
              ),
        child:  Row(
        children: [
          Text('Complaint ID: $compId'),
          const SizedBox(width: 10,),
          Text('Type: $comptype'),
        ],
      ),
      ),
      children: <Widget>[
        ListTile(
          title: StepProgress(userId: userId, compId: compId),
        ),
      ],
    );
  }
}

class StepProgress extends StatefulWidget {
  final int userId;
  final int compId;

  const StepProgress({super.key, required this.userId, required this.compId});

  @override
  _StepProgressState createState() => _StepProgressState();
}

class _StepProgressState extends State<StepProgress> {
  String _compType = '';
  String _compStatus = '';
  String _date = '';
  String _time = '';

  final List<String> statuses = [
    'pending',
    'acknowledged',
    'in progress',
    'completed'
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.userId, widget.compId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:const EdgeInsets.all(10),
      decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                              color: const Color.fromARGB(124, 255, 47, 47),
                              width: 2,
                            ),
              ),
      child:  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_compType.isNotEmpty && _compStatus.isNotEmpty && _date.isNotEmpty && _time.isNotEmpty)
          ComplaintDetails(
            compType: _compType,
            compStatus: _compStatus,
            date: _date,
            time: _time,
          ),
        const SizedBox(height: 20),
        const Text('Status Progress:'),
        const SizedBox(height: 10),
        Row(
          children: statuses.map((status) {
            bool isActive = statuses.indexOf(status) <= statuses.indexOf(_compStatus);
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 10.0,
                      backgroundColor: isActive ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 4.0),
                    Text(status, style: const TextStyle(fontSize: 12.0)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    )
    );
  }

  Future<void> fetchUserData(int userId, int compId) async {
    final response = await http.post(
      Uri.parse('http://$globalP/db_complaint_details.php'),
      body: {
        'userId': userId.toString(),
        'compId': compId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['error'] == null) {
        setState(() {
          _compType = data['compType'];
          _compStatus = data['compStatus'];
          _date = data['date'];
          _time = data['time'];
        });
      } else {
        // Handle the error
        print(data['error']);
      }
    } else {
      throw Exception('Failed to load user data');
    }
  }
}

class ComplaintDetails extends StatelessWidget {
  final String compType;
  final String compStatus;
  final String date;
  final String time;

  const ComplaintDetails({super.key, 
    required this.compType,
    required this.compStatus,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type: $compType'),
        Text('Status: $compStatus'),
        Text('Date: $date'),
        Text('Time: $time'),
      ],
    );
  }
}
