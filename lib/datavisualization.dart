import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_responsive_login_ui/globalip.dart';
import 'package:http/http.dart' as http;

class DataVisualizationPage extends StatefulWidget {
  @override
  _DataVisualizationPageState createState() => _DataVisualizationPageState();
}

class _DataVisualizationPageState extends State<DataVisualizationPage> {
  List<ComplaintTypeData> typeData = [];
  String globalip = globalP;

  @override
  void initState() {
    super.initState();
    _fetchComplaintData();
  }

  // Fetch complaint data from backend
  Future<void> _fetchComplaintData() async {
    final response = await http.get(Uri.parse('http://$globalip/fetch_complaints_admin.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('Fetched data: $data');  // Debugging

      setState(() {
        typeData = data.map((e) {
          final count = e['count'] ?? 1;  // Ensure count is never zero or negative
          final type = e['com_type'] ?? 'Unknown';  // Default to 'Unknown' if type is missing
          print('Parsed data: Type: $type, Count: $count'); // Debugging
          return ComplaintTypeData(type, count);
        }).toList();
      });
    } else {
      print('Failed to load data: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Data Visualization'),
      ),
      body: typeData.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading spinner while data is fetched
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Complaint Type Distribution Pie Chart
                  Container(
                    height: 300,
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ComplaintTypePieChart(data: typeData),
                  ),
                ],
              ),
            ),
    );
  }
}

class ComplaintTypePieChart extends StatelessWidget {
  final List<ComplaintTypeData> data;

  const ComplaintTypePieChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: Text('No data available'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,  // Adjust spacing
          centerSpaceRadius: 40,  // Adjust center space radius
          sections: data
              .map((data) {
                final sanitizedCount = data.count > 0 ? data.count.toDouble() : 1.0;
                print('Adding section: ${data.type}, Value: $sanitizedCount');
                return PieChartSectionData(
                  value: sanitizedCount,
                  color: data.type == 'metro' ? Colors.blue : Colors.green,
                  title: '${data.type}: ${data.count}',
                );
              })
              .toList(),
        ),
      ),
    );
  }
}

class ComplaintTypeData {
  final String type;
  final int count;

  ComplaintTypeData(this.type, this.count);

  @override
  String toString() => 'Type: $type, Count: $count'; // Added for debugging
}
