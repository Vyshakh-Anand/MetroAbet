import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/AdminDashboard.dart';
import 'package:flutter_responsive_login_ui/widgets/gradient_button.dart';
import 'package:flutter_responsive_login_ui/widgets/login_field.dart';
import 'package:flutter_responsive_login_ui/registration_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';


import 'package:flutter_responsive_login_ui/dashboard.dart';
import 'AuthService.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  // Function to handle sign-in button press
  void _onSignInPressed(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String email = _emailController.text;
    String password = _passwordController.text;
    final response = await _authService.loginUser(email, password);

    setState(() {
      _isLoading = false;
    });

    if (response['message'] == 'Login successful') {
      print(response['user_type']);
      
      if (response['user_type']=="user"){
      int userId = response['user_id'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen(userId: userId)),
      );
      }
      else{
        int userId = response['user_id'];
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard(userId: userId)),
      );
      }
    } else {
      setState(() {
        _errorMessage = response['message'];
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 186, 27, 27).withOpacity(.7),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          children: [
            // White background shape
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
            // SVG image behind the sign-in container
           /*Positioned(
  bottom: 20, // Set to 0 to align it with the bottom edge of the parent container
  left: 40, // Set to 0 to align it with the left edge of the parent container
  child: Center(
    child: SvgPicture.asset(
      'assets/svgs/metro.svg',
      width: 300,
      height: 300,
      fit: BoxFit.cover,
    ),
  ),
),*/

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 186, 27, 27).withOpacity(0),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: _buildHeader(),
                    ),
                  ),
                  SizedBox(height: 50),
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Sign in...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Color.fromARGB(255, 255, 161, 161),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField('Email', _emailController, obscureText: false),
                          const SizedBox(height: 10),
                          _buildTextField('Password', _passwordController, obscureText: true),
                          const SizedBox(height: 20),
                          GradientButton(
                            buttonText: 'Sign in',
                            onPressed: () => _onSignInPressed(context),
                          ),
                          const SizedBox(height: 20),
                          if (_isLoading)
                            CircularProgressIndicator(),
                          if (_errorMessage != null)
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red),
                            ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RegistrationScreen()),
                              );
                            },
                            child: const Text(
                              "New user? Register here",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 255, 185, 185),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
    return Row(
      children: [
        const Text(
          'Metro Abet',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 60,
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

  Widget _buildTextField(String hintText, TextEditingController controller, {required bool obscureText}) {
    return LoginField(
      hintText: hintText,
      obscureText: obscureText,
      controller: controller,
    );
  }
}
