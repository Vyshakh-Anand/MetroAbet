import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/login_screen.dart';
import 'package:flutter_responsive_login_ui/widgets/gradient_button.dart';
import 'package:flutter_responsive_login_ui/widgets/login_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'globalip.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _phoneError;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
void showWarning(String title, String message, IconData icon, Color color, [Function? redirect]) {
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
                    icon,
                    color: color,
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (redirect != null) {
                            redirect();
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

Future<void> _registerUser(BuildContext context) async {
  // Reset previous error messages
  setState(() {
    _usernameError = null;
    _emailError = null;
    _passwordError = null;
    _phoneError = null;
  });

  String username = _usernameController.text;
  String email = _emailController.text;
  String password = _passwordController.text;
  String phone = _phoneController.text;

  // Validation
  if (username.isEmpty) {
    setState(() {
      _usernameError = 'Username is required';
    });
    return;
  }

  if (email.isEmpty) {
    setState(() {
      _emailError = 'Email is required';
    });
    return;
  }

  if (password.isEmpty) {
    setState(() {
      _passwordError = 'Password is required';
    });
    return;
  }

  if (phone.isEmpty) {
    setState(() {
      _phoneError = 'Phone is required';
    });
    return;
  }

  final Uri uri = Uri.parse('http://$globalP/register.php');

  try {
    final response = await http.post(
      uri,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'phone': phone,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Check the response body to ensure registration was successful
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData.containsKey('message') && responseData['message'] == 'Registration successful') {
        // Registration successful, navigate to login screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else if (responseData.containsKey('error')) {
        // Registration failed, handle error (show error message, etc.)
        if (responseData['error'] == 'Email already exists') {
          setState(() {
            _emailError = 'Email already exists';
          });
          showWarning('Registration Error', 'Email already exists', Icons.error, Colors.red);
        } else if (responseData['error'] == 'Phone already in use') {
          setState(() {
            _phoneError = 'Phone already in use';
          });
          showWarning('Registration Error', 'Phone already in use', Icons.error, Colors.red);
        } else {
          showWarning('Registration Error', 'An unknown error occurred.', Icons.error, Colors.red);
        }
      }
    } else {
      // Handle non-200 status codes
      showWarning('Registration Error', 'An unknown error occurred.', Icons.error, Colors.red);
    }
  } catch (e) {
    // Exception occurred during the HTTP request
    print('Error registering user: $e');
    // Display an error message to the user if needed
    showWarning('Registration Error', 'An error occurred while registering. Please try again later.', Icons.error, Colors.red);
  }
}



  @override
  void initState() {
    super.initState();

    // Add listeners to text controllers for continuous validation
    _usernameController.addListener(_validateUsername);
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _phoneController.addListener(_validatePhone);
  }

  void _validateUsername() {
    setState(() {
      if (_usernameController.text.isEmpty) {
        _usernameError = 'Username is required';
      } else if (_usernameController.text.length < 3) {
        _usernameError = 'Username must be at least 3 characters long';
      } else {
        _usernameError = null;
      }
    });
  }

  void _validateEmail() {
    setState(() {
      if (_emailController.text.isEmpty) {
        _emailError = 'Email is required';
      } else if (!_isEmailValid(_emailController.text)) {
        _emailError = 'Invalid email format';
      } else {
        _emailError = null;
      }
    });
  }

  bool _isEmailValid(String email) {
    // Regular expression for basic email validation
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _validatePassword() {
    setState(() {
      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password is required';
      } else if (_passwordController.text.length < 6) {
        _passwordError = 'Password must be at least 6 characters long';
      } else if (!_isPasswordValid(_passwordController.text)) {
        _passwordError =
            'Password must contain at least one lowercase letter, one uppercase letter, and one digit';
      } else {
        _passwordError = null;
      }
    });
  }

  bool _isPasswordValid(String password) {
    // Regular expression for password validation
    final RegExp passwordRegex =
        RegExp(r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9]).{6,}$');
    return passwordRegex.hasMatch(password);
  }

  void _validatePhone() {
    setState(() {
      if (_phoneController.text.isEmpty) {
        _phoneError = 'Phone is required';
      } else if (!_isPhoneNumberValid(_phoneController.text)) {
        _phoneError = 'Invalid phone number';
      } else {
        _phoneError = null;
      }
    });
  }

  bool _isPhoneNumberValid(String phone) {
    // Basic phone number validation (10 digits)
    final RegExp phoneRegex = RegExp(r'^[0-9]{10}$');
    return phoneRegex.hasMatch(phone);
  }

  @override
  void dispose() {
    // Clean up listeners to avoid memory leaks
    _usernameController.removeListener(_validateUsername);
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword);
    _phoneController.removeListener(_validatePhone);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 186, 27, 27).withOpacity(.7),
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: Stack(
          children: [
            // White background shape
            Positioned(
              top: 140, // Adjust as needed for the desired vertical position
              left: -(MediaQuery.of(context).size.width * 0.5), // Adjust as needed for the horizontal position
              right: -(MediaQuery.of(context).size.width * 0.5), // Adjust as needed for the horizontal position
              child: ClipOval(
                child: Container(
                  color: const Color.fromARGB(104, 205, 205, 205),
                  width: MediaQuery.of(context).size.width * 2, // Double the width to ensure it covers the entire screen
                  height: MediaQuery.of(context).size.height * 1.2, // Extend the height beyond the screen bottom
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20), // Adjust padding as needed
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 186, 27, 27).withOpacity(0),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20), // Adjust the radius to change the curvature
                        bottomRight: Radius.circular(20), // Adjust the radius to change the curvature
                      ),
                    ),
                    child: Center(
                      child: _buildHeader(),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 166, 33, 243),
                            Color.fromARGB(255, 227, 64, 64)
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                LoginField(
                  hintText: 'User name',
                  controller: _usernameController,
                  errorText: _usernameError,
                ),
                const SizedBox(height: 15),
                LoginField(
                  hintText: 'Email',
                  controller: _emailController,
                  errorText: _emailError,
                ),
                const SizedBox(height: 15),
                LoginField(
                  hintText: 'Password',
                  controller: _passwordController,
                  errorText: _passwordError,
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                LoginField(
                  hintText: 'Phone',
                  controller: _phoneController,
                  errorText: _phoneError,
                ),
                const SizedBox(height: 20),
                GradientButton(
                  buttonText: 'Register',
                  onPressed: () {
                    _registerUser(context);
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Navigate to the login screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text(
                    "Already a member? Login now",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 255, 185, 185),
                      fontWeight: FontWeight.normal,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
          fontSize: 60,
          color: Color.fromARGB(255, 255, 255, 255),
          letterSpacing: 2.0,
        ),
      ),
      SizedBox(width: 10), // Adjust the width as needed
      Icon(
        Icons.train,
        color: Colors.white, // Adjust the color as needed
        size: 40, // Adjust the size as needed
      ),
    ],
  );
}

}
