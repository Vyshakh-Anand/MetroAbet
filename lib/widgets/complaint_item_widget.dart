import 'package:flutter/material.dart';

class ComplaintItemWidget extends StatefulWidget {
  final int compId;
  final String type;
  final String status;
  final String date;
  final String time;
  final String details;
  final Function(int compId, String newState) onChangeState;

  const ComplaintItemWidget({
    Key? key,
    required this.compId,
    required this.type,
    required this.status,
    required this.date,
    required this.time,
    required this.details,
    required this.onChangeState,
  }) : super(key: key);

  @override
  _ComplaintItemWidgetState createState() => _ComplaintItemWidgetState();
}

class _ComplaintItemWidgetState extends State<ComplaintItemWidget> {
  String? selectedState; // Track the selected state

  // Show custom confirmation dialog similar to showWarningSend
  void _showConfirmationDialog(String cat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 700,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(51, 168, 168, 168),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromARGB(124, 255, 47, 47),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: Colors.orange,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Confirm State Change',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Are you sure you want to change the state of this complaint?',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog first
                            if (selectedState != null) {
                              widget.onChangeState(widget.compId, selectedState!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a state first'),
                                ),
                              );
                            }
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Complaint ID: ${widget.compId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text(
                    widget.status,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: widget.status.toLowerCase() == 'resolved'
                      ? Colors.green
                      : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Type: ${widget.type}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              'Date: ${widget.date} | Time: ${widget.time}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              'Details:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.details,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedState,
                    hint: const Text('Select State'),
                    items: const [
                      DropdownMenuItem(
                        value: 'acknowledged',
                        child: Text('Acknowledged'),
                      ),
                      DropdownMenuItem(
                        value: 'in progress',
                        child: Text('In Progress'),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('Completed'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedState = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (selectedState != null) {
                      _showConfirmationDialog('someCategory'); // Pass category if needed
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a state first'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Change State'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
