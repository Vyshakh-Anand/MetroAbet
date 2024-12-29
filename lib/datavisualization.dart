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
  Map<String, dynamic> data = {};
  String globalIp = globalP;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://$globalIp/fetch_complaints_datavisualization.php'));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
        });
      } else {
        print('Error fetching data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complaint Data Visualization")),
      body: data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              children: [
                buildSectionTitle("Complaint Type Distribution"),
                buildPieChartWithLegend(data['type_distribution'] ?? []),
                SizedBox(height: 20),
                buildSectionTitle("Complaint Trends Over Time"),
                buildLineChart(data['trends'] ?? []),
                SizedBox(height: 20),
                buildSectionTitle("Complaint Status Distribution"),
                buildGaugeChart(data['status_distribution'] ?? []),
                SizedBox(height: 20),
                buildSectionTitle("Complaint Location Distribution"),
                buildHeatMapWithLegend(data['location_distribution'] ?? []), // Heat Map visualization here
              ],
            ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Pie Chart with Legends
  Widget buildPieChartWithLegend(List<dynamic> data) {
    List<PieChartSectionData> pieChartSections = data.map((entry) {
      return PieChartSectionData(
        value: double.parse(entry['count']),
        title: entry['count'],
        color: _getSectionColor(entry['type']),
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pie Chart
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: pieChartSections,
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        // Legends
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: _getSectionColor(entry['type']),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry['type'],
                        style: TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Line Chart for Trends
  Widget buildLineChart(List<dynamic> data) {
    List<FlSpot> spots = data.map((entry) {
      DateTime date = DateTime.parse(entry['complaint_date']);
      return FlSpot(date.millisecondsSinceEpoch.toDouble(), double.parse(entry['total_complaints'])); // Convert date to milliseconds
    }).toList();

    spots.sort((a, b) => a.x.compareTo(b.x));

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: Text('Complaints'),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString(), style: TextStyle(fontSize: 10));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: Text('Date'),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 7 * 24 * 60 * 60 * 1000, 
                getTitlesWidget: (value, meta) {
                  DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text("${date.day}/${date.month}", style: TextStyle(fontSize: 10)),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10),
        ),
      ),
    );
  }

  // Custom Gauge Chart for Status Distribution
  Widget buildGaugeChart(List<dynamic> data) {
    double resolved = 0;
    double pending = 0;
    data.forEach((entry) {
      if (entry['comp_status'] == 'completed') resolved = double.parse(entry['count']);
      if (entry['comp_status'] == 'pending') pending = double.parse(entry['count']);
    });

    double total = resolved + pending;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          size: Size(200, 200), // Size of the gauge
          painter: GaugePainter(resolved / total), // Pass the percentage value
        ),
        SizedBox(width: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Resolved: ${(resolved / total * 100).toStringAsFixed(1)}%"),
            Text("Pending: ${(pending / total * 100).toStringAsFixed(1)}%"),
          ],
        ),
      ],
    );
  }

  // Heat Map for Location Distribution
Widget buildHeatMapWithLegend(List<dynamic> data) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Heatmap
      Expanded(
        flex: 3, // Occupy 3/4 of the screen for the heatmap
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10, // Increase the number of columns for a denser heatmap
            crossAxisSpacing: 2.0, // Reduce the spacing between cells
            mainAxisSpacing: 2.0, // Reduce vertical spacing
          ),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            var entry = data[index];
            String location = entry['location'] ?? 'Unknown';
            double value = (entry['count'] != null) ? double.tryParse(entry['count'].toString()) ?? 0.0 : 0.0;

            // Get the heatmap color based on the value
            Color cellColor = _getHeatMapColor(value);

            return Container(
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(5.0), // Rounded corners for smoother cells
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  location,  // Display the metro/station name
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            );
          },
        ),
      ),
      SizedBox(width: 16), // Add some spacing between the heatmap and legend

      // Legend
      Expanded(
        flex: 1, // Occupy 1/4 of the screen for the legend
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Legend",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildLegendItem("Low Complaints", Colors.blue[200]!),
            _buildLegendItem("Moderate Complaints", Colors.green[300]!),
            _buildLegendItem("High Complaints", Colors.orange[400]!),
            _buildLegendItem("Very High Complaints", Colors.red[500]!),
          ],
        ),
      ),
    ],
  );
}


Widget _buildLegendItem(String label, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.0),
            border: Border.all(color: Colors.black.withOpacity(0.3)),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    ),
  );
}


Color _getHeatMapColor(double value) {
  // Define a color range: Blue for low values, Red for high values
  if (value <= 5) {
    return Colors.blue[200]!; // Low complaint count - Light blue
  } else if (value <= 15) {
    return Colors.green[300]!; // Moderate complaint count - Green
  } else if (value <= 30) {
    return Colors.orange[400]!; // Higher complaint count - Orange
  } else {
    return Colors.red[500]!; // Very high complaint count - Red
  }
}



  Color _getSectionColor(String key) {
    return Colors.primaries[key.hashCode % Colors.primaries.length];
  }
}

// CustomPainter for the Gauge
class GaugePainter extends CustomPainter {
  final double percentage;

  GaugePainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    Paint foregroundPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    // Draw the background circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    // Draw the foreground arc (gauge)
    double sweepAngle = (percentage / 100) * 2 * 3.1416;
    Rect rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2);
    canvas.drawArc(rect, -3.1416 / 2, sweepAngle, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
