import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/pallete.dart';

class LoginField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final String? errorText; // Change errorText type to String
  final TextEditingController? controller;

  const LoginField({
    Key? key,
    required this.hintText,
    this.obscureText = false,
    this.errorText, // Update errorText parameter
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(27),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Pallete.borderColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 255, 255, 255),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: hintText,
            ),
          ),
          if (errorText != null) // Display error message if errorText is not null
            Padding(
              padding: const EdgeInsets.only(top: 8), // Adjust top padding as needed
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: Colors.red, // Customize error message color
                  fontSize: 12, // Customize error message font size
                ),
              ),
            ),
        ],
      ),
    );
  }
}
