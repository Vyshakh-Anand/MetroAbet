import 'dart:collection';
import 'dart:convert';
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

import 'package:http/http.dart' as http;
import 'globalip.dart';



class DashboardScreen extends StatefulWidget {
  final int userId;
  const DashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isExpanded = false;
  String _name = '';
  String _phone = '';
  String _email = '';
  bool _isLoading = false;
  List<DropdownMenuItem<String>> datas = [];
  List<dynamic> _complaints = [];
  List<String> _complaintList = [];
    List<String> _complaintListStation = [];
  String? _selectedComplaint;
  String? _selectedMetroNumber;
  String? _ticketNo;
  DateTime? _incidentDate;
  TimeOfDay? _incidentTime;
  PickedFile? _image;
  String? _grievanceDescription;
  String? _selectedStationNumber;
    String globalip=globalP;
int _currentTabIndex = 0;
  String? _complainttype;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
   // Initialize to null

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchUserComplaints();
    _fetchComplaintsList();
    fetchData('metro');
    _fetchComplaintsListStation();
  }

Future<void> fetchData(String type) async {
  setState(() {
    _isLoading = true; // Show loading indicator
  });
  try {
    final response = await http.get(Uri.parse('http://${globalip}/fetchData.php?type=$type'));

    if (response.statusCode == 200) {
      print('Response body: ${response.body}'); // Print the response body

      List<dynamic> jsonData = json.decode(response.body);

      setState(() {
        if (type == 'metro') {
          datas = jsonData.map<DropdownMenuItem<String>>((metro) {
            return DropdownMenuItem<String>(
              value: metro['metro_no'].toString(),
              child: Text("${metro['metro_no']} "),
              //- From: ${metro['from_loc']} To: ${metro['to_loc']}
            );
          }).toList();
        } else if (type == 'station') {
          // Handle station data similarly if needed
          datas = jsonData.map<DropdownMenuItem<String>>((station) {
            return DropdownMenuItem<String>(
              value: station['station_no'].toString(),
              child: Text("${station['station_no']} "),
              //- From: ${metro['from_loc']} To: ${metro['to_loc']}
            );
          }).toList();
        }
      });
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print('Error fetching data: $e');
    // Optionally, show a user-friendly message
  } finally {
    setState(() {
      _isLoading = false; // Hide loading indicator
    });
  }
}

  void resetState() {
  setState(() {
    // Reset all relevant variables to their initial values
    _selectedMetroNumber = null;
    _selectedStationNumber = null;
    _ticketNo = null;
    _incidentDate = null;
    _incidentTime = null;
    _image = null;
    _grievanceDescription = null;
    _selectedComplaint = null;
    _formKey.currentState?.reset(); // Reset form fields if using Form widget
  });
}
  Future<void> _fetchComplaintsList() async {
    final response = await http.get(Uri.parse('http://${globalip}/fetch_complaintsList.php?category=metro'));

    if (response.statusCode == 200) {
      print('Response data: ${response.body}'); // Print the response data

      setState(() {
        _complaintList = List<String>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load complaints');
    }
  }

  Future<void> _fetchComplaintsListStation() async {
    final response = await http.get(Uri.parse('http://${globalip}/fetch_complaintsList.php?category=station'));

    if (response.statusCode == 200) {
      print('Response data: ${response.body}'); // Print the response data

      setState(() {
        _complaintListStation = List<String>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load complaints');
    }
  }


  Future<void> fetchUserComplaints() async {
  setState(() {
    _isLoading = true;
  });

  final response = await http.get(Uri.parse('http://${globalip}/fetch_complaints.php?userId=${widget.userId}'));

  if (response.body == null) {
    // Handle null response body
    setState(() {
      _isLoading = false;
    });
    throw Exception('Response body is null');
  }

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['complaints'] != null) {
      // Extract only specific fields from the complaints data
      List<dynamic> complaintsData = data['complaints'];
      _complaints = complaintsData.map((complaintData) => {
        'comp_id': complaintData['comp_id'],
        'type': complaintData['type']
      }).toList();
    }

    setState(() {
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

  // Convert property values to strings
  String? convertToString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }
 void showWarningSend(String title, String message, IconData icon, Color color,String cat) {
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
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromARGB(51, 168, 168, 168),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color.fromARGB(124, 255, 47, 47),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    message,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog first
                          saveComplaint(cat); // Then call the saveComplaint function
                        },
                        child: Text('OK'),
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


void showWarning( String title, String message, IconData icon, Color color,[Function? redirect]) {
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
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromARGB(51, 168, 168, 168),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                              color: Color.fromARGB(124, 255, 47, 47),
                              width: 2,
                            ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    message,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          redirect;
                        },
                        child: Text('OK'),
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

Future<void> fetchUserData() async {
  print(globalip);
  final response = await http.get(Uri.parse('http://${globalip}/fetchuserdata.php?userId=${widget.userId}'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    setState(() {
      _name = data['name'];
      _phone = data['phno'].toString();
      _email = data['email'];
    });
  } else {
    throw Exception('Failed to load user data');
  }
}
Future<void> _selectDate(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
  );
  if (pickedDate != null && pickedDate != _incidentDate)
    setState(() {
      _incidentDate = pickedDate;
    });
}

Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _incidentTime)
      setState(() {
        _incidentTime = pickedTime;
      });
  }


  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }
Future<void> saveComplaint(String cat) async {
  print("heere");
  final url = Uri.parse('http://${globalip}/newcomplaint.php');
   List<int> imageBytes = await _image!.readAsBytes();
     String base64Image = base64Encode(imageBytes);
 String formattedDate = _incidentDate != null ? DateFormat('yyyy-MM-dd').format(_incidentDate!) : '';
  String formattedTime = _incidentTime != null ? "${_incidentTime!.hour.toString().padLeft(2, '0')}:${_incidentTime!.minute.toString().padLeft(2, '0')}:00" : '';
       print('userId: ${widget.userId}');
  print('metroNo: $_selectedMetroNumber');
  print('stationNo: $_selectedStationNumber');
  print('date: $formattedDate');
  print('time: $formattedTime');
  print('type: $_selectedComplaint');
  print('photo: $base64Image');
  print('compDetails: $_grievanceDescription');
  print('comType: $cat');
  final response = await http.post(
    url,
    body: {
      'userId': widget.userId.toString(),
      'metroNo': _selectedMetroNumber ?? '',
      'stationNo': _selectedStationNumber ?? '',
      'date': formattedDate,
      'time': formattedTime,
      'type': _selectedComplaint,
      'photo': base64Image,
      'compDetails': _grievanceDescription ?? '',
      'comType': cat,
    },
  );

  final responseData = json.decode(response.body);
  if (responseData['success'] == true) {
    showWarning('SUCCESS','Your complaint has been posted',Icons.check_circle_outline_outlined, Colors.green, resetState);
    resetState();
  } else {
    // Error saving data
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with transparency
          Positioned.fill(
            child: Container(
              color: Color.fromARGB(255, 255, 94, 94).withOpacity(.7),
            ),
          ),
          Positioned(
            top: 140,
            left: -(MediaQuery.of(context).size.width * 0.5),
            right: -(MediaQuery.of(context).size.width * 0.5),
            child: ClipOval(
              child: Container(
                color: Color.fromARGB(104, 205, 205, 205),
                width: MediaQuery.of(context).size.width * 2,
                height: MediaQuery.of(context).size.height * 1.2,
              ),
            ),
          ),
          // Main content
          Positioned(
            top: 0,
            left: 10,
            right: 10,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: _buildHeader(),
                    ),
                  ),
                  // Collapsible box
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 100),

                    width: MediaQuery.of(context).size.width * 3, // Adjust the width as needed
                    child: 
_buildCollapsibleBox(widget.userId,_complaints),
                  ),
                  
                  DefaultTabController(
                    length: 2,
                    initialIndex: _currentTabIndex,
          child: Column(
            children: [
              TabBar(
                onTap: (index) {
                  setState(() {
                    
                    _currentTabIndex = index; // Update the current tab index
                    if (index == 0) {
                      fetchData('metro');
                      _complainttype="metro";
                      _selectedStationNumber = 'null';
                    } else {
                      fetchData('station');
                      _complainttype="station";
                      _selectedMetroNumber = 'null'; // Set _selectedStationNumber to null
                    }
                  });
                   resetState(); 
                },
                          tabs: [
                            Tab(
                              icon: Icon(Icons.train),
                              text: 'Metro',
                            ),
                            Tab(
                              icon: Icon(Icons.location_city),
                              text: 'Station',
                            ),
                          ],
                        ),
                        Container(
                          height: 500,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(0, 199, 113, 249),
                                Color.fromARGB(142, 227, 64, 64)
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                            border: Border.all(
                              color: Color.fromARGB(255, 255, 255, 255),
                              width: 2,
                            ),
                          ),
                          child: TabBarView(
  children: [
Row(
  children: [
    Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildPersonalInfoForm(),
        ),
      ),
    ),
    VerticalDivider( // Add VerticalDivider here
      color: Color.fromARGB(255, 224, 123, 255), // Customize the color of the divider
      thickness: 1.0, // Adjust the thickness of the divider
    ),
    Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 166, 33, 243),
                Color.fromARGB(255, 227, 64, 64)
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: Color.fromARGB(255, 255, 255, 255),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Column(
              children: [
                SizedBox(height: 10,),
                Text(
                  "Grievance Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Select Complaint"),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  margin: EdgeInsets.only(left: 10),
                                  child: DropdownButtonHideUnderline(
                                    child: GFDropdown(
                                      padding: const EdgeInsets.all(5),
                                      borderRadius: BorderRadius.circular(5),
                                      border: const BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 1),
                                      dropdownButtonColor: Color.fromARGB(255, 255, 255, 255),
                                      value: _selectedComplaint,
                                      hint: Text("ComplaintList"),
                                      onChanged: (dynamic newValue) {
                                        setState(() {
                                          _selectedComplaint = newValue as String?;
                                        });
                                      },
                                      items: _complaintList.map((String complaint) {
                                        return DropdownMenuItem<String>(
                                          value: complaint,
                                          child: Container(
                                            width: 500, // Set the width to the maximum the parent can give
                                            color: Colors.white, // Set the background color to white
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                              complaint,
                                              style: TextStyle(color: Colors.black),
                                              // Set the text color to black
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: double.infinity, // Adjust the width as needed
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), // White color with opacity for semi-transparency
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12, // Light shadow
                blurRadius: 10, // Blur effect
                spreadRadius: 5, // Spread of the shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Padding inside the container
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
               Form(
  key: _formKey,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
    children: [
      Row(
        children: [
          Text("Metro Number", style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
          SizedBox(width: 12,),
          Container(
            width: 200,
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text('Select Metro Number'),
              value: _selectedMetroNumber,
              items: datas,
              onChanged: (newValue) {
                setState(() {
                  _selectedMetroNumber = newValue;
                });
              },
            ),
          ),
        ],
      ),
      SizedBox(height: 16.0),
      Text("Ticket No", style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
      TextFormField(
        onChanged: (value) {
          setState(() {
            _ticketNo = value;
          });
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter Ticket No',
        ),
        // Add validator for required field
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter Ticket No';
          }
          return null;
        },
      ),
      SizedBox(height: 16.0),
      Text("Incident Date", style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
      Row(
        children: [
          Expanded(
            child: Text(_incidentDate == null
                ? 'Select Date'
                : DateFormat('yyyy-MM-dd').format(_incidentDate!), textAlign: TextAlign.left),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: Text(_incidentTime == null
                ? 'Select Time'
                : _incidentTime!.format(context), textAlign: TextAlign.left),
          ),
          IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () => _selectTime(context),
          ),
        ],
      ),
      SizedBox(height: 16.0),
      Text("Attach Image", style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
      Row(
        children: [
          _image == null
              ? Text('No image selected.', textAlign: TextAlign.left)
              : Image.network(_image!.path, height: 50),
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: _pickImage,
          ),
        ],
      ),
      SizedBox(height: 16.0),
      Text("Grievance Description", style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
      TextFormField(
        maxLines: 4,
        onChanged: (value) {
          setState(() {
            _grievanceDescription = value;
          });
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter Grievance Description',
        ),
        // Add validator for required field
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter Grievance Description';
          }
          return null;
        },
      ),
      SizedBox(height: 16.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GFButton(
            text: "Post Complaint",
            onPressed: () {
              // Validate form before submitting
              if (_formKey.currentState!.validate()) {
                print("Button click");
                showWarningSend("WARNING", "Do you want to file the complaint?\nMake sure all the information is correct", Icons.warning_rounded, Colors.red,"metro");
              }
            },
            shape: GFButtonShape.standard,
          ),
        ],
      ),
    ],
  ),
)
        
              ],
            ),
          ),
        ),
      ),
    )


                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ],
),
Row(
  //station here
  children: [
    Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildPersonalInfoForm(),
        ),
      ),
    ),
    VerticalDivider( // Add VerticalDivider here
      color: Color.fromARGB(255, 224, 123, 255), // Customize the color of the divider
      thickness: 1.0, // Adjust the thickness of the divider
    ),
    Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 166, 33, 243),
                Color.fromARGB(255, 227, 64, 64)
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: Color.fromARGB(255, 255, 255, 255),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Column(
              children: [
                SizedBox(height: 10,),
                Text(
                  "Grievance Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Select Complaint"),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  margin: EdgeInsets.only(left: 10),
                                  child: DropdownButtonHideUnderline(
                                    child: GFDropdown(
                                      padding: const EdgeInsets.all(5),
                                      borderRadius: BorderRadius.circular(5),
                                      border: const BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 1),
                                      dropdownButtonColor: Color.fromARGB(255, 255, 255, 255),
                                      value: _selectedComplaint,
                                      hint: Text("ComplaintList"),
                                      onChanged: (dynamic newValue) {
                                        setState(() {
                                          _selectedComplaint = newValue as String?;
                                        });
                                      },
                                      items: _complaintListStation.map((String complaint) {
                                        return DropdownMenuItem<String>(
                                          value: complaint,
                                          child: Container(
                                            width: 500, // Set the width to the maximum the parent can give
                                            color: Colors.white, // Set the background color to white
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                              complaint,
                                              style: TextStyle(color: Colors.black),
                                              // Set the text color to black
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: double.infinity, // Adjust the width as needed
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), // White color with opacity for semi-transparency
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12, // Light shadow
                blurRadius: 10, // Blur effect
                spreadRadius: 5, // Spread of the shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Padding inside the container
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
               Form(
  key: _formKey,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
    children: [
      Row(
        children: [
          Text("Station Number", style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
          SizedBox(width: 12,),
          Container(
            width: 200,
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text('Select Station Number'),
              value: _selectedStationNumber,
              items: datas,
              onChanged: (newValue) {
                setState(() {
                  _selectedStationNumber = newValue;
                });
              },
            ),
          ),
        ],
      ),
      SizedBox(height: 16.0),
      Text("Ticket No", style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
      TextFormField(
        onChanged: (value) {
          setState(() {
            _ticketNo = value;
          });
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter Ticket No',
        ),
        // Add validator for required field
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter Ticket No';
          }
          return null;
        },
      ),
      SizedBox(height: 16.0),
      Text("Incident Date", style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
      Row(
        children: [
          Expanded(
            child: Text(_incidentDate == null
                ? 'Select Date'
                : DateFormat('yyyy-MM-dd').format(_incidentDate!), textAlign: TextAlign.left),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: Text(_incidentTime == null
                ? 'Select Time'
                : _incidentTime!.format(context), textAlign: TextAlign.left),
          ),
          IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () => _selectTime(context),
          ),
        ],
      ),
      SizedBox(height: 16.0),
      Text("Attach Image", style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
      Row(
        children: [
          _image == null
              ? Text('No image selected.', textAlign: TextAlign.left)
              : Image.network(_image!.path, height: 50),
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: _pickImage,
          ),
        ],
      ),
      SizedBox(height: 16.0),
      Text("Grievance Description", style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
      TextFormField(
        maxLines: 4,
        onChanged: (value) {
          setState(() {
            _grievanceDescription = value;
          });
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter Grievance Description',
        ),
        // Add validator for required field
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter Grievance Description';
          }
          return null;
        },
      ),
      SizedBox(height: 16.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GFButton(
            text: "Post Complaint",
            onPressed: () {
              // Validate form before submitting
              if (_formKey.currentState!.validate()) {
                print("Button click");
                showWarningSend("WARNING", "Do you want to file the complaint?\nMake sure all the information is correct", Icons.warning_rounded, Colors.red, '');
              }
            },
            shape: GFButtonShape.standard,
          ),
        ],
      ),
    ],
  ),
)
        
              ],
            ),
          ),
        ),
      ),
    )


                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ],
),
  ],
),

                        ),
                      ],
                    ),
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
    return Row(
      children: [
        const Text(
          'Metro Abet',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40,
            color: Color.fromARGB(255, 255, 255, 255),
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(width: 10),
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
            color: Color.fromARGB(255, 255, 255, 255),
            border: Border.all(
              color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
              width: 1.0,
              
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ExpansionTile(
            title: Text(
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









  Widget buildPersonalInfoForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your personal information",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            icon: Icon(Icons.person),
            labelText: 'Name',
          ),
          controller: TextEditingController(text: _name),
          readOnly: false,
        ),
        SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            icon: Icon(Icons.phone),
            labelText: 'Phone',
          ),
          controller: TextEditingController(text: _phone),
          readOnly: false,
        ),
        SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            icon: Icon(Icons.email),
            labelText: 'Email',
          ),
          controller: TextEditingController(text: _email),
          readOnly: false,
        ),
     
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DashboardScreen(userId: 1),
  ));
}
